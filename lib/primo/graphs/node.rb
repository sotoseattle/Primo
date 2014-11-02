class Node
  private

  attr_writer :vars, :neighbors

  public

  attr_accessor :bag
  attr_reader :vars, :neighbors

  def initialize(*variables)
    @vars  = Array(variables).flatten.uniq.sort
    @neighbors = []
    @bag = {}

    fail ArgumentError if vars.empty?
  end

  def connect(other)
    return if other == self || neighbors.include?(other)

    neighbors  << other
    other.neighbors << self
  end

  def isolate!
    neighbors.each { |n| n.neighbors.delete(self) }
    self.neighbors = []
  end

  def isolated?
    neighbors.empty?
  end

  def weight
    vars.map(&:card).reduce(:*)
  end

  def to_s
    "Node [#{vars.join('-')}]"
  end
end
