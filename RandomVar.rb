class RandomVar

  attr_reader :card, :ass, :name

  def initialize(card, name='', ass=nil)
    @card = card.to_i
    @name = name.to_s
    @ass = (ass ? Array(ass) : (0...@card).to_a)
    raise ArgumentError.new if @card==0
    raise ArgumentError.new if @ass.size!=@card
  end

  def <=>(other)
    self.object_id <=> other.object_id
  end

  def to_s
    "#{@name}"
  end

end
