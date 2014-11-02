module Tree
  include Graph

  def leaf
    nodes.first { |n| n.neighbors.size == 1 }
  end

  def prune_tree
    neighbor = true
    while neighbor
      nodes.find do |node|
        bridge(neighbor, node) if (neighbor = subset_of?(node))
      end
    end
  end

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

  private

  def subset_of?(n)
    n.neighbors.find { |m| (n.vars - m.vars).empty? }
  end

  def bridge(super_set_node, sub_set_node)
    link_between(super_set_node, sub_set_node.neighbors)
    delete!(sub_set_node)
  end
end
