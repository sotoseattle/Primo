require 'rubygems'

require_relative './Graph'

class InducedMarkovNet < Graph
	# undirected graph where each node holds a single random variable
	# nodes connected if show up together in a factor

	attr_accessor :factors

	def initialize(factors)
		@factors = factors

		all_vars = @factors.map{|f| f.vars}.flatten.uniq
		super(all_vars)

    @factors.each do |f|
    	nodes = f.vars.map do |v| 
    		@nodes.index{|b| b.include?(v)}
    	end
    	connect_all(nodes)
    end
	end

	def first_min_neighbor_var
    minino, pos = Float::INFINITY, nil
    @edges.each_with_index do |a, i|
    	s = a.size
      if s>0 and s<minino
      	minino, pos = s, i 
      end
    end
    return [pos, @nodes[pos].first]
  end
end




