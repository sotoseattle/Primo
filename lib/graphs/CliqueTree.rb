class Node
   private
   attr_writer :incoming
   public
   attr_reader :incoming

   def incoming
     @incoming ||= [nil]*edges.size
   end

  def get_message_from(n)
    return incoming[edges.index(n)]
  end
  def save_message_from(n, delta)
    self.incoming[edges.index(n)]= delta
  end
end

class CliqueTree
  # include Graphium
  include Tree

  def initialize(*bunch_o_factors)
    factors = Array(bunch_o_factors)
    @is_max = false
    @nodes = generate_tree(factors.map(&:clone))
    prune_tree
    setup_working_variables
    assign_factors(factors)
  end

  def set_MAP
    is_max = true
  end

  def calibrate
    message_path.each{|step| compute_delta(*step)}
    nodes.each{|n| compute_beliefs(n)}
  end


  private

  # Build a clique tree using variable elimination algorithm.
  # Returns the set of linked nodes that define the graph
  def generate_tree(factors_array)
    tree_nodes = []
    workip = FactorArray.new(factors_array)
    markov = InducedMarkov.new(factors_array)
    tau = nil
    while markov.nodes.size>0
      pick_node = markov.loneliest_node
      pick_var  = pick_node.vars[0]
      factors_with_pick = workip.select{|f| f.holds?(pick_var)}
      
      if tau = workip.eliminate_variable!(pick_var)
        # tree: new nodes
        new_vars = tau.vars + [pick_var]
        new_node = Node.new(new_vars)
        tree_nodes << new_node
        # tree: new edges
        clique = tree_nodes.select{|n| factors_with_pick.include? n.bag[:tau]}
        link_between(new_node, clique)

        # store the tau in its node
        new_node.bag[:tau] = tau
        # modify induced markov for next iteration
        tau.vars.each{|v| markov.link_all_with(v)}
        markov.delete!(pick_node)
      end
    end
    tau.vars.each{|v| markov.link_all_with(v)}
    return tree_nodes
  end
  
  def setup_working_variables
    nodes.each do |n|
      n.bag.delete(:tau)
      n.bag[:phi] = (Factor.new(n.vars) + 1).norm
      n.bag[:beta] = nil
    end
  end

  # Associate to each node the product of factors that share variables
  def assign_factors(factors_array)
    factors_array.each do |f|
      nn = sort_by_vars.find{|n| (f.vars-n.vars).empty?}
      nn.bag[:phi] *= f
      nn.bag[:phi].norm
    end
  end

  # Return the complete path (firing messages sequence)
  # Traversing the tree both ways. Each step = [from_node, to_node]
  def message_path
    forwards = cascade_path
    backwards = forwards.reverse.map{|a| a.reverse}
    return (forwards + backwards)
  end

  # Gather potential and incomming available messages and multiply/add
  def process_incomming_messgs(n)
    incoming_mssgs = n.edges.map{|m| n.get_message_from(m)}
    bunch = FactorArray.new([n.bag[:phi]] + incoming_mssgs)
    return bunch.product
  end

  def compute_delta(origin, target)
    delta = process_incomming_messgs(origin)
    setsep_vars = (origin.vars & target.vars)
    (delta.vars - setsep_vars).each do |v|
      delta % v
    end
    target.save_message_from(origin, delta)
  end

  def compute_beliefs(n)
    n.bag[:beta] = process_incomming_messgs(n)
  end

  def check_coherence
    h = {}
    variables = nodes.each do |n| 
      n.vars.each do |v|
        if h[v]
          h[v] << n
        else
          h[v] = [n]
        end
      end
    end
    h.each do |v, arr_n|
      puts "rv: #{v}"
      
      arr_n.each do |n|
        puts "  n: #{n}"
        puts n.bag[:beta].vals.sum
        # puts (n.bag[:beta].clone.marginalize_all_but(v)).vals.to_a.join(" .. ")
      end
      
      
    end
  end
  


end
