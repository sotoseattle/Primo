# A Clique Tree is such a complex thing that I divide its code between
# a generator (just to build it) and the class itself (calibrate and infer)

class TreeGenerator ### WORK ON THIS


	# def grow_tree(*args)
	# 	raise NotImplementedError, 'method should be override'
	# end

 #  def prune_tree # <====== REFACTOR IN SINGLE METHOD CALL
 #    while keep_prunning? do
 #    end
 #  end

  # def keep_prunning?
  #   # Start with a node (A), scan through its neighbors to find one that is
  #   # a superset of variables (B). Add edges between B and all of A's other
  #   # neighbors and cut off all edges from A
  #   nodes_idx = nodes.each_index.select{|i| !nodes[i].empty?}
  #   nodes_filled = nodes_idx.size
  #   nodes_idx.each do |i|
  #     edges[i].each do |j|
  #       if nodes[i].subset?(nodes[j])
  #         # connect nodeB to other nodeA's neighbors
  #         edges[i].each{|e| self.add_edge(j,e)}
  #         # erase all info from pruned node
  #         edges[i] = []     # <====== Maybe we dont need both cleared before reindexing
  #         nodes[i].clear    # <====== Maybe we dont need both cleared before reindexing
  #         nodes_filled -= 1
  #         # remove all reference of pruned node in other node's links
  #         edges.each_with_index do |neighbors, k|
  #           if neighbors.include?(i)
  #             edges[k].delete(i)
  #           end
  #         end
  #         return nodes_filled>2
  #       end
  #     end
  #   end
  #   return false
  # end

 #  def reindex_tree
 #    dict = {}
 #    new_index = 0
 #    nodes.each_with_index do |set, old_index|
 #      unless set.empty?
 #        dict[old_index] = new_index
 #        new_index +=1
 #      end
 #    end
 #    new_tot = new_index
 #    nodes, links = []*new_tot, Array.new(new_tot){[]}
 #    dict.each do |old_index, new_index|
 #      nodes[new_index] = nodes[old_index]
 #      links[new_index] = edges[old_index].map{|old_link| dict[old_link]}
 #    end
 #    nodes, edges, size = nodes, links, new_tot
 #  end

 #  def bfs_path(start)
 #  	# Breadth First Search algorithm for DAGs
 #    raise ArgumentError.new() if start==nil

 #    discoveryPath = []
 #    marked = [false]*size
 #    edgeTo = [nil]*size
 #    distTo = [Float::INFINITY]*size
    
 #    distTo[start] = 0
 #    marked[start] = true
 #    queue = [start]
 #    while queue.size>0 do
 #      v = queue.pop
 #      discoveryPath << v
 #      edges[v].each do |w|
 #        if marked[w]==false
 #          edgeTo[w] = v
 #          distTo[w] = distTo[v] + 1
 #          marked[w] = true
 #          queue.unshift(w)
 #        end
 #      end
 #    end

 #    return discoveryPath  
 #  end
end