class Phenotype < RandomVar
  def initialize(name)
    super(card: 2, name: name, ass: %w(present absent))
  end
end

class Genotype < RandomVar
  HardCodedValues = [1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5,
                     0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.5, 0.0,
                     0.5, 0.5, 0.0, 0.0, 1.0]
  def initialize(name)
    super(card: 3, name: name, ass: %w(FF Ff ff))
  end
end

class AlleleType < RandomVar
  def initialize(name)
    super(card: 3, name: name, ass: %w(F f n))
  end
end
