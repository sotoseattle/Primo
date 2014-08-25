class Node

  private
  attr_writer :vars, :edges
  public
  attr_accessor :bag
  attr_reader :vars, :edges

  def initialize(*variables)
    @vars  = Array(variables).flatten.uniq.sort # is sort needed?
    @edges = []
    @bag = {}
    raise ArgumentError if vars.empty?
  end

  def connect(other)
    return if other==self
    unless edges.include?(other)
      self.edges  << other 
      other.edges << self
    end
  end

  def isolate!
    edges.each{|n| n.edges.delete(self)}
    self.edges = []
  end

  def isolated?
    edges.empty?
  end

  def weight
    vars.map(&:card).reduce(:*)
  end

  def to_s
    "Node [#{vars.join('-')}]"
  end
end