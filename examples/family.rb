class Family
  attr_reader :members

  def initialize(names)
    @members = names.map { |name| Person.new(name) }
  end

  def compute_factors
    members.each(&:compute_factors)
  end

  def compute_whole_joint
    fs = members.map(&:factor)
    fs.unshift(fs.first.to_ones)
    fs.reduce { |a, e| (a * e).norm }
  end

  def [](name)
    members.find { |p| p.name == name }
  end
end
