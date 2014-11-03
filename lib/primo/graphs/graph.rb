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
    nodes << n
    n
  end

  def add_neighbors(*bunch_o_nodes)
    Array(bunch_o_nodes.flatten).combination(2).each { |n1, n2| n1.connect(n2) }
  end
  alias_method :make_clique, :add_neighbors

  def link_between(node, *bunch_o_nodes)
    Array(bunch_o_nodes.flatten).each { |n| add_neighbors(node, n) }
  end

  def link_all_with(v)
    clique = nodes.select { |n| n.vars.include?(v) }
    add_neighbors(clique)
  end

  def disconnect(n)
    n.isolate!
  end

  def delete!(node)
    disconnect(node)
    nodes.delete(node)
  end

  def sort_by_neighbors
    nodes.sort { |a, b| a.neighbors.size <=> b.neighbors.size }
  end

  def sort_by_vars
    nodes.sort { |a, b| a.vars.size <=> b.vars.size }
  end

  def loneliest_node
    sort_by_neighbors.find { |n| n.neighbors.size >= 0 }
  end

  def thinnest_node
    nodes.min { |n1, n2| n1.weight <=> n2.weight }
  end

  def breadth_first_search_path(start)
    path = []
    queue = [start]
    visited = Hash.new(false)
    visited[start] = true
    while queue.size > 0
      n = queue.shift
      path << n
      n.neighbors.each do |w|
        unless visited[w]
          visited[w] = true
          queue << w
        end
      end
    end
    path
  end

  def to_s
    reduce("#{nodes.size} nodes\n") { |a, e| a << " #{e}: #{e.neighbors.join(' || ')}\n" }
  end
end
