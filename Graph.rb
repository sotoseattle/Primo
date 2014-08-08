class Graph # Undirected Graph

	attr_reader :size, :nodes, :edges

  def initialize(variable_groups=[])
    @nodes = variable_groups.map{|e| Set.new(Array(e))}
    @size = @nodes.size
    @edges = Array.new(@size){[]}
  end

  def add_vertex(contents)
  	n = Set.new(contents)
    @nodes << n
    @edges << []
    @size += 1
    return n
  end

  def add_edge(v,w)
  	v, w = v.to_i, w.to_i
  	raise ArgumentError.new() if v>=@size or v<0 or w>=@size or w<0
    return if v==w
    @edges[v] << w unless @edges[v].include?(w)
    @edges[w] << v unless @edges[w].include?(v)
  end
  
  def connect_all(xyz)
    while xyz.size>1 do
      a = xyz.pop
      xyz.each{|b| add_edge(a,b)}
    end
  end

  def to_s
    s = "#{@size} vertices\n"
    @nodes.each_with_index do |v,i|
    	s << "[#{i}] #{v.to_a.join(',')}: "
    	s << "#{@edges[i].map{|e| @nodes[e].to_a.join(',')}.join(' || ')}\n"
    end
    return s
  end
end




