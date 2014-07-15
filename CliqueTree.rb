require 'rubygems'

require_relative './Tree'
require_relative './InducedMarkovNet'
require_relative './Factor'

class CliqueTree < Tree


  attr_reader :betas

  def initialize(factors)
    super()
    grow_tree(factors)
    prune_tree
    reindex_tree
    initialize_potentials(factors)
    @deltas, @betas = nil, nil
  end

  def calibrate(is_max=false)
    @betas = []
    @deltas = @edges.map{|e| Array.new(e.size)}
    
    itinerary = compute_path()
    compute_messages(itinerary, is_max)
    compute_beliefs(is_max)
  end

  def grow_tree(factors)
    # using variable elimination algorithm on the Induced Markov Network
    taus = []
    g = InducedMarkovNet.new(factors)
    g.size.times do
      target_pos, target_var = g.first_min_neighbor_var
      work_f, idle_f = g.factors.partition do |f| 
        f.vars.include?(target_var)
      end
    
      unless work_f.empty?
        # add a node to clique tree with the variables involved
        new_node = self.add_vertex(work_f.map{|f| f.vars}.flatten)
        
        # see if new node's tau uses other nodes' taus and connect
        taus.each_with_index do |t,i|
          self.add_edge(i, @size-1) if work_f.include?(t)
        end
        
        tau = work_f.pop.clone
        work_f.each{|fu| tau.multiply!(fu, false)}
        tau.marginalize!(target_var)
        taus << tau
        
        # connect nodes of vars inside new factor (in g)
        xyz = new_node.map{|v| g.nodes.index{|b| b.include?(v)}}
        g.connect_all(xyz)
        # ...and disconnect the eliminated var (in g)
        g.edges[target_pos] = []
        
        # add to unused factors the new tau (new factor with var eliminated)
        g.factors = (idle_f << tau)
      end
    end
  end
  
  def initialize_potentials(factors)
    @factors = [nil]*@nodes.size
    factors.each do |f|
      i = @nodes.index{|n| Set.new(f.vars).subset?(n)}
      if @factors[i]
        @factors[i].multiply!(f, false)
      else
        @factors[i] = f.clone
      end
    end
    @factors.each_with_index do |f, i|
      if !f # null factors initialized to ones
        n = @nodes[i]
        length = n.inject(1){|t,e| t*=e.card}
        @factors[i] = Factor.new(n, [1.0]*length)
      end
    end
  end

  def compute_path
    # the way to pass messages is the reverse of the BFS path
    # every node in the path is ensured to have received
    # all necessary incoming messages
    starting_node = @edges.index{|e| e.size==1}
    path = bfs_path(starting_node).reverse()
    path.pop # we don't need the last one

    jumps = []
    marked = [false]*@size
    path.each do |from_node|
      marked[from_node] = true
      to_node = @edges[from_node].select{|n| !marked[n]}
      raise Exception("Too many targets") if to_node.size>1
      jumps << [from_node, to_node[0]]
    end
    
    path = jumps + jumps.reverse.map{|e| e.reverse}
    return path
  end

  def mssg(from_v, to_w, is_max)
    # collect all mssg arriving at v
    mess = []
    neighbors = @edges[from_v]
    neighbors.each do |i|
      if i!=to_w
        pos = @edges[i].index(from_v)
        msg = @deltas[i][pos]
        mess << msg
      end
    end
    
    # take the the initial Psi (and log if needed)
    d = @factors[from_v].clone  #### IS THIS DEEP COPY??
    d.vals = d.vals.log if is_max
    
    # multiply/sum by incoming messages
    mess.each do |ms|
      is_max ? d.sum!(ms, false) : d.multiply!(ms, false)
    end

    # marginalized to setsep vars
    d.vars.each do |rv|
      if !(@nodes[from_v] & @nodes[to_w]).include?(rv)
        is_max ? d.max_marginalize!(rv) : d.marginalize!(rv)
      end
    end
    return d
  end

  def compute_messages(path, is_max)
    path.each do |jump|
      from_v, to_w = jump
      pos_to = @edges[from_v].index(to_w)
      @deltas[from_v][pos_to] = mssg(from_v, to_w, is_max)
    end
  end

  def compute_beliefs(is_max)
    # compute the beliefs
    (0...@size).each do |v|
      belief = @factors[v].clone
      belief.vals = belief.vals.log if is_max
      
      @edges[v].each do |w|
        pos = edges[w].index(v)
        delta = @deltas[w][pos]
        is_max ? belief.sum!(delta, false) : belief.multiply!(delta, false)
      end
      @betas[v] = belief
    end
  end

end






