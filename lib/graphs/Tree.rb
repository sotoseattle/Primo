# Role of Tree, additional methods for an specific graph.

module Tree
  include Graphium

  # Returns a leaf in a tree
  def leaf
    return nodes.first{|n| n.edges.size==1}
  end

  # Removes nodes whose variables are a subset of another node and 
  # relinks the superset with the subset's neighbors
  def prune_tree
    go_on = true
    while go_on
      go_on = false
      # sort_by_vars.each do |n|
      nodes.each do |n|
        # kk = n.edges.sort{|a, b| a.vars.size<=>b.vars.size}.reverse
        neighbor = n.edges.find{|m| (n.vars - m.vars).empty?}
        if neighbor
          link_between(neighbor, n.edges)
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
      to = from.edges.find{|n| marked[n]==false}
      [from,to]
    end
    path.pop
    return path
  end
end
  
