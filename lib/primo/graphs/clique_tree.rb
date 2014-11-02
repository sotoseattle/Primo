class CliqueTree
  include Tree

  def initialize(*bunch_o_factors)
    factors = Array(bunch_o_factors)
    @nodes = generate_tree_nodes(factors.map(&:clone))
    prune_tree
    setup_working_variables
    initialize_potentials(factors)
  end

  def calibrate
    message_path.each { |step| compute_message(*step) }
    nodes.each { |n| compute_belief(n) }
  end

  def query(variable, assignment = nil)
    node = nodes.find { |n| n.vars.include?(variable) }
    my_beta = node.bag[:beta].clone.marginalize_all_but(variable)
    b = my_beta.norm.vals.to_a
    assignment ? b[variable[assignment]] : b
  end

  private

  def generate_tree_nodes(factors_array)
    tree_nodes = []
    wip = FactorArray.new(factors_array)
    markov = InducedMarkov.new(factors_array)

    while markov.nodes.size > 0
      pick_node = markov.loneliest_node
      pick_var  = pick_node.vars.first
      factors_with_pick = wip.select { |f| f.holds?(pick_var) }

      if (tau = wip.eliminate_variable!(pick_var))
        new_node = tree_new_node(tau, pick_var)
        tree_nodes << new_node
        clique = tree_nodes.select { |n| factors_with_pick.include? n.bag[:tau] }
        link_between(new_node, clique)

        markov = modify_markov(markov, tau, pick_node)
      end
    end
    tau.vars.each { |v| markov.link_all_with(v) }
    tree_nodes
  end

  def tree_new_node(tau, variable)
    node = Node.new(tau.vars + [variable]).extend(Messenger)
    node.bag[:tau] = tau
    node
  end

  def modify_markov(markov, tau, node_to_eliminate)
    tau.vars.each { |v| markov.link_all_with(v) }
    markov.delete!(node_to_eliminate)
    markov
  end

  def setup_working_variables
    nodes.each do |n|
      n.bag.delete(:tau)
      n.bag[:phi] = (Factor.new(vars: n.vars) + 1).norm
      n.bag[:beta] = nil
    end
  end

  def initialize_potentials(factors_array)
    factors_array.each do |f|
      nn = sort_by_vars.find { |n| (f.vars - n.vars).empty? }
      nn.bag[:phi] *= f
      nn.bag[:phi].norm
    end
  end

  def message_path
    forwards = cascade_path
    backwards = forwards.reverse.map(&:reverse)
    (forwards + backwards)
  end

  def incomming_messages(n, silent_node = nil)
    transmitters = n.neighbors.reject { |e| e == silent_node }
    messages = transmitters.map { |m| n.get_message_from(m) }
    messages
  end

  def compute_message(origin, target)
    delta = [origin.bag[:phi]] + incomming_messages(origin, target)
    delta = FactorArray.new(delta).product(true)
    setsep_vars = (origin.vars & target.vars)
    (delta.vars - setsep_vars).each { |v| delta % v }
    target.save_message_from(origin, delta)
  end

  def compute_belief(n)
    beta = [n.bag[:phi]] + incomming_messages(n)
    n.bag[:beta] = FactorArray.new(beta).product(true)
  end
end
