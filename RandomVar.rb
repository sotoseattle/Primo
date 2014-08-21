class RandomVar

  attr_reader :id, :card, :ass, :name

  def initialize(id, card, name='', ass=nil)
    @id = id.to_i
    @card = card.to_i
    @name = name.to_s
    @ass = (ass ? Array(ass) : (0...@card).to_a)
    raise ArgumentError.new if @card==0
    raise ArgumentError.new if @ass.size!=@card
  end

  def ==(other)
    id == other.id
  end

  def <=>(other)
    id <=> other.id
  end

  def to_s
    "#{@name}" #"#{self.class}: [id: #{@id}] card: #{@card} '#{@name}'"
  end

end
