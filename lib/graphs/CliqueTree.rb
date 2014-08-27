
class CliqueTree
  include Tree

  def initialize(*bunch_o_factors)
    factors = Array(bunch_o_factors)
    @nodes = generate_tree(factors.map(&:clone))
    prune_tree
    setup_working_variables
    initialize_potentials(factors)
  end

  def calibrate
    message_path.each{|step| compute_message(*step)}
    nodes.each{|n| compute_belief(n)}
  end

  # Returns probability of variable assignment on calibrated tree
  def query(variable, assignment=nil)
    n = nodes.find{|n| n.vars.include?(variable)}
    my_beta = n.bag[:beta].clone.marginalize_all_but(variable)
    b = my_beta.norm.vals.to_a
    if assignment
      return b[variable[assignment]]
    else
      return b
    end    
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
        new_node.extend(Messenger)
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
      n.bag[:phi] = (Factor.new({vars:n.vars}) + 1).norm
      n.bag[:beta] = nil
    end
  end

  # Associate to each node the product of factors that share variables
  def initialize_potentials(factors_array)
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

  # Gather incomming messages to the node
  # Optional, disregard messages from the node we may transmit to
  def incomming_messages(n, silent_node=nil)
    transmitters = n.neighbors.reject{|e| e==silent_node}
    messages = transmitters.map{|m| n.get_message_from(m)}
    return messages
  end

  # Compute delta message as cumproduct of potential and incoming messages
  def compute_message(origin, target)
    delta = [origin.bag[:phi]] + incomming_messages(origin, target)
    delta = FactorArray.new(delta).product(true)
    setsep_vars = (origin.vars & target.vars)
    (delta.vars - setsep_vars).each{|v| delta % v}
    target.save_message_from(origin, delta)
  end

  # Compute beta as cumproduct of potential and incoming messages
  def compute_belief(n)
    beta = [n.bag[:phi]] + incomming_messages(n)
    n.bag[:beta] = FactorArray.new(beta).product(true)
  end

  
  


end
