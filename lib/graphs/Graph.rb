# Role of an undirected graph.
# Just a collection of nodes referenced by injection,
# although it manages the edges between nodes, it is the node itself
# the one who knows who he is linked to and actually creates the edge.

module Graph
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
  def add_neighbors(*bunch_o_nodes)
    Array(bunch_o_nodes.flatten).combination(2).each do |node_pair|
      node_pair[0].connect(node_pair[1])
    end
  end
  alias_method :make_clique, :add_neighbors

  # Connect node to a bunch of others (but not among themselves)
  def link_between(node, *bunch_o_nodes)
    Array(bunch_o_nodes.flatten).each do |n|
      add_neighbors(node, n)
    end
  end

  # Make a clique of all nodes that share a certain variable
  def link_all_with(v)
    clique = nodes.select{|n| n.vars.include?(v)}
    add_neighbors(clique)
  end

  # Ask node to remove all its neighbors
  def disconnect(n)
    n.isolate!
  end
  
  # Remove node completely from graph
  def delete!(node)
    disconnect(node)
    nodes.delete(node)
  end

  # Return nodes sorted by number of neighbors
  def sort_by_neighbors
    nodes.sort{|a, b| a.neighbors.size<=>b.neighbors.size}
  end
  def sort_by_vars
    nodes.sort{|a, b| a.vars.size<=>b.vars.size}
  end

  # Returns the node with the least neighbors
  # Useful for min-neighbors algorithm
  def loneliest_node
    return sort_by_neighbors.find{|n| n.neighbors.size>=0}
  end

  # Returns the node with the least cummulative cardinality
  # Useful for min-weight algorithm
  def thinnest_node
    return nodes.min{|n1,n2| n1.weight<=>n2.weight}
  end
  
  # Breadth First Search algorithm
  def breadth_first_search_path(start)
    path = []
    visited = Hash.new(false)
    visited[start] = true
    queue = [start]
    while queue.size>0
      n = queue.shift
      path << n
      n.neighbors.each do |w|
        unless visited[w]
          visited[w] = true
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
      s << " #{n}: #{n.neighbors.join(' || ')}\n"
    end
    return s
  end
end