class RandomVar

  attr_reader :id, :card, :ass, :name, :opts

  def initialize(id, card, name='', ass=nil, opts={})
    @id = id.to_i

    @card = card.to_i
    if ass
      ass = Array(ass)
      raise ArgumentError.new() if ass.size!=@card
      @ass = ass
    else
      @ass = (0...@card).to_a
    end
    
    @name = name.to_s
    @opts = opts.to_h

    raise ArgumentError.new() if @card==0
  end

  def ==(other)
    self.id == other.id
  end

  def <=>(other)
    @id <=> other.id
  end

  def to_s
    #"#{self.class}: [id: #{@id}] card: #{@card} '#{@name}'"
    "#{@name}"
  end

end
