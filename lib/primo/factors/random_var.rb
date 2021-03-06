class RandomVar
  attr_reader :card, :ass, :name

  def initialize(args)
    args.merge(name: '', ass: nil)

    @card = args[:card].to_i
    @name = args[:name].to_s
    @ass = args[:ass] ? Array(args[:ass]) : [*0...@card]

    fail ArgumentError if @card == 0 || @ass.size != @card
  end

  def <=>(other)
    object_id <=> other.object_id
  end

  def [](assignment)
    ass.index(assignment)
  end

  def to_s
    "#{name}"
  end
end
