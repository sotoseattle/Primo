
class CliqueTree
   include Graphium
   include Factium

  def initialize(*bunch_o_factors)
    @nodes = []
    @factors = Array(bunch_o_factors)

    generate_tree
    simplify_graph
    setup_working_variables
    assign_factors
  end

  def calibrate
  end



  private

  # Build a clique tree using variable elimination algorithm.
  # The induced graph is modified and consumed in place,
  # as are the referenced factors, so we backup them up.
  def generate_tree
    keep_factors = factors.map{|f| f.clone}
    markov = InducedMarkov.new(self.factors)

    (markov.nodes.size-1).times do
      pick_node = markov.loneliest_node
      pick_var  = pick_node.vars[0]
      factors_with_pick = factors.select{|f| f.holds?(pick_var)}

      if tau = eliminate_variable!(pick_var)
        # tree: new nodes
        new_vars = tau.vars + [pick_var]
        new_node = add_node(new_vars)
        new_node.bag[:tau] = tau
        # tree: new edges
        clique = nodes.select{|n| factors_with_pick.include? n.bag[:tau]}
        link_between(new_node, clique)
        # induced markov: modify edges
        new_vars.each{|v| markov.link_all_with(v)}
        markov.disconnect(pick_node)
      end
    end
    self.factors = keep_factors
  end
  
  def setup_working_variables
    nodes.each do |n|
      n.bag.delete(:tau)
      n.bag[:phi] ||= Factor.new(n.vars) + 1.0
      n.bag[:delta] = nil
      n.bag[:beta] = nil
    end
  end

  # Associate to each node the product of factors that share variables
  def assign_factors
    sorted_nodes = nodes.sort{|a,b| a.vars.size<=>b.vars.size}
    factors.each do |f|
      nn = sorted_nodes.find{|n| (f.vars-n.vars).empty?}
      # puts "#{f} ===> #{nn}"
      nn.bag[:phi] *= f
    end
  end

  # Return the complete path (firing messages sequence)
  def message_path
    forwards = breadth_first_search_path(loneliest_node)
    backwards = path.reverse.map{|a| a.reverse}
    return (forwards + backwards)
  end  


end
