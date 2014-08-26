# Role of an undirected graph.
# Just a collection of nodes referenced by injection,
# although it manages the edges between nodes, it is the node itself
# the one who knows who he is linked to and actually creates the edge.

module Graphium
  private
  attr_writer :nodes
  public
  attr_reader :nodes

  def nodes
    @nodes ||= []
  end

  def add_node(*variables)
    n = Node.new(*variables)
    nodes << n ### BEWARE REPETITION OF NODES
    return n
  end

  # Connect with edge two nodes, or multiple nodes as a clique
  def add_edges(*bunch_o_nodes)
    Array(bunch_o_nodes.flatten).combination(2).each do |node_pair|
      node_pair[0].connect(node_pair[1])
    end
  end
  alias_method :make_clique, :add_edges

  # Connect node to a bunch of others (but not among themselves)
  def link_between(node, *bunch_o_nodes)
    Array(bunch_o_nodes.flatten).each do |n|
      add_edges(node, n)
    end
  end

  # Make a clique of all nodes that share a certain variable
  def link_all_with(v)
    clique = nodes.select{|n| n.vars.include?(v)}
    add_edges(clique)
  end

  # Ask node to remove all its edges
  def disconnect(n)
    n.isolate!
  end
  
  # Returns the node with the least edges
  # Useful for min-neighbors algorithm
  def loneliest_node
    sorted_by_edges = nodes.sort{|a, b| a.edges.size<=>b.edges.size}
    return sorted_by_edges.find{|n| n.edges.size>0}
  end

  # Returns the node with the least cummulative cardinality
  # Useful for min-weight algorithm
  def thinnest_node
    return nodes.min{|n1,n2| n1.weight<=>n2.weight}
  end

  # Removes nodes whose variables are a subset of another node and 
  # relinks the superset with the subset's neighbors
  def simplify_graph
    to_remove = []
    nodes.each do |n|
      n.edges.each do |neighbor|
        if n.vars.all?{|v| neighbor.vars.include? v}
          link_between(neighbor, n.edges)
          n.isolate!
          to_remove << n
        end
     end
    end
    to_remove.each{|n| nodes.delete(n)}
  end

  # Breadth First Search algorithm
  def breadth_first_search_path(start)
    path = []
    visited = Hash.new(false)
    visited[start] = true
    queue = [start]
    while queue.size>0
      n = queue.shift
      n.edges.each do |w|
        unless visited[w]
          visited[w] = true
          path << [n,w]
          queue << w
        end
      end
    end
    return path
  end

  # Return an array of nodes whose variables include the variables input.
  # def get_superset(var_array)
  #   sol = nodes.select{|n| (var_array-n.vars).empty?}
  #   return sol.sort{|a,b| a.vars.size<=>b.vars.size}
  # end

  def to_s
    s = "#{nodes.size} nodes\n"
    nodes.each do |n|
      s << " #{n}: #{n.edges.join(' || ')}\n"
    end
    return s
  end
end