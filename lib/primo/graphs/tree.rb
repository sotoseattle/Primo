# Role of Tree, additional methods for an specific graph.

module Tree
  include Graph

  # Returns a leaf in a tree
  def leaf
    nodes.first { |n| n.neighbors.size == 1 }
  end

  # Removes nodes whose variables are a subset of another node and
  # relinks the superset with the subset's neighbors
  def prune_tree
    go_on = true
    while go_on
      go_on = false
      nodes.each do |n|
        neighbor = n.neighbors.find { |m| (n.vars - m.vars).empty? }
        if neighbor
          link_between(neighbor, n.neighbors)
          delete!(n)
          go_on = true
          break
        end
      end
    end
  end

  # Return a message path where each nodes fires only after all neighbors
  # have passed messages. Based on the discovery path of Breadth First Search
  def cascade_path
    discovery_bfs_path = breadth_first_search_path(leaf)
    marked = Hash.new(false)
    path = discovery_bfs_path.reverse.map do |from|
      marked[from] = true
      to = from.neighbors.find { |n| marked[n] == false }
      [from, to]
    end
    path.pop
    path
  end
end
