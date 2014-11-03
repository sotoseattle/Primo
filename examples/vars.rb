class Phenotype < RandomVar
  def initialize(name)
    super(card: 2, name: name, ass: %w(present absent))
  end
end

class Genotype < RandomVar
  def initialize(name)
    super(card: 3, name: name, ass: %w(FF Ff ff))
  end
end

class AlleleType < RandomVar
  def initialize(name)
    super(card: 3, name: name, ass: %w(F f n))
  end
end
