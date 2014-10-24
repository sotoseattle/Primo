# CYSTIC FIBROSIS BAYESIAN NETWORK DECOUPLED
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations

require_relative '../../lib/primo'

class PhenoType < RandomVar
  def initialize(name)
    super({ card: 2, name: name, ass: %w(present absent) })
  end
end

class AlleleType < RandomVar
  def initialize(name)
    super({ card: 3, name: name, ass: %w(F f n) })
  end
end

class Person
  private

  attr_accessor :factor, :dad, :mom

  public

  attr_reader :name, :allel_1, :allel_2, :pheno, :factor

  def initialize(name)
    @name = name
    @pheno = PhenoType.new(name)
    @allel_1 = AlleleType.new(name)
    @allel_2 = AlleleType.new(name)
  end

  def is_son_of(daddy, mommy)
    self.dad = daddy
    self.mom = mommy
  end

  def alleles_factors_probabilistic
    f1 = Factor.new(vars: [allel_1], vals: [0.1, 0.7, 0.2])
    f2 = Factor.new(vars: [allel_2], vals: [0.1, 0.7, 0.2])
    (f1 * f2).norm
  end

  def alleles_factors_genetic
    vals = [1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.5, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0]
    f1 = Factor.new(vars: [allel_1, dad.allel_1, dad.allel_2], vals: vals)
    f2 = Factor.new(vars: [allel_2, mom.allel_1, mom.allel_2], vals: vals)
    (f1 * f2).norm
  end

  def phenotype_factor
    vars = [pheno, allel_1, allel_2]
    vals = [0.8, 0.2, 0.6, 0.4, 0.1, 0.9, 0.6, 0.4, 0.5, 0.5, 0.05, 0.95, 0.1, 0.9, 0.05, 0.95, 0.01, 0.99]
    Factor.new(vars: vars, vals: vals)
  end

  def compute_factors
    self.factor = phenotype_factor
    factor * ((dad && mom) ? alleles_factors_genetic : alleles_factors_probabilistic)
    factor.norm
  end

  def observe_pheno(ass)
    factor.reduce(pheno => ass).norm
  end

  def observe_gens(ass)
    factor.reduce(allel_1 => ass[0]).reduce(allel_2 => ass[1]).norm
  end
end

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
    fs.reduce { |a, b| (a * b).norm }
  end

  def [](name)
    members.find { |p| p.name == name }
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################
# Beware, adding Sandra makes the joint CPD so huge that it blows
# a segmentation bug because the resulting NArray is too big

# a = Family.new(%w{Ira Robin Aaron Rene James Eva Sandra Jason Benito})
# a = Family.new(%w{Ira Robin Rene James Eva Benito Sandra})
a = Family.new(%w(Ira Robin Rene James Eva Benito))

a['James'].is_son_of(a['Ira'], a['Robin'])
a['Eva'].is_son_of(a['Ira'], a['Robin'])
# a['Sandra'].is_son_of(a['Aaron'], a['Eva'])
# a['Jason'].is_son_of(a['James'], a['Rene'])
a['Benito'].is_son_of(a['James'], a['Rene'])

a.compute_factors

a['Ira'].observe_pheno('present')
a['Rene'].observe_gens(%w(F f))
a['Eva'].observe_pheno('present')

Benito_pheno = a.compute_whole_joint.marginalize_all_but(a['Benito'].pheno)
puts "Probability of Benito showing illness: #{Benito_pheno['present']}"

# no reductions      => P(Benito ill present) == 0.3554
# only Ira reduction => P(Benito ill present) == 0.39008
# all reductions     => P(Benito ill present) == 0.54095
