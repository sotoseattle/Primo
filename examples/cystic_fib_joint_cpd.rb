# GENETIC BAYESIAN NETWORK I
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations

require 'primo'

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

class Person
  private

  attr_accessor :factor, :dad, :mom

  public

  attr_reader :name, :gen, :phn, :factor

  PHENO_STATS = { 'FF' => 0.8, 'Ff' => 0.6, 'ff' => 0.1 }
  GEN_STATS = { 'F' => 0.1, 'f' => 0.9 }

  def initialize(name)
    @name = name
    @phn = Phenotype.new(name)
    @gen = Genotype.new(name)
    @dad = nil
    @mom = nil
  end

  def is_son_of(daddy, mommy)
    self.dad = daddy
    self.mom = mommy
  end

  def compute_factors
    self.factor = phen_probabistic(PHENO_STATS)
    factor * ((dad && mom) ? gen_parental : gen_probabilistic(GEN_STATS))
    factor.norm
  end

  def phen_probabistic(stats)
    values = gen.ass.map { |g| [stats[g], 1 - stats[g]] }
    Factor.new(vars: [phn, gen], vals: values)
  end

  # VERY FUGLY AND COUPLED
  # REFACTOR AND GENERALIZE ALL GEN_
  def gen_probabilistic(stats)
    combis = %w(F f).product(%w(F f)).map { |e| e.sort.join }
    values = gen.ass.map do |k|
      combis.count(k) * (stats[k[0]] * stats[k[1]])
    end
    Factor.new(vars: [gen], vals: values)
  end

  def gen_parental
    na = NArray.float(3, 3, 3)
    dad.gen.ass.each_with_index do |dad_gen, i|
      mom.gen.ass.each_with_index do |mom_gen, j|
        d, m = dad_gen.split(''), mom_gen.split('')
        combinations = d.product(m).map { |e| e.sort.join }
        na[true, i, j] = gen.ass.map { |k| combinations.count(k) / 4.0 }
      end
    end
    Factor.new(vars: [gen, dad.gen, mom.gen], vals: na)
  end

  def observe_pheno(ass)
    factor.reduce(phn => ass).norm
  end

  def observe_gen(ass)
    factor.reduce(gen => ass).norm
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

a = Family.new(%w(Ira Robin Aaron Rene James Eva Sandra Jason Benito))

a['James'].is_son_of(a['Ira'], a['Robin'])
a['Eva'].is_son_of(a['Ira'], a['Robin'])
a['Sandra'].is_son_of(a['Aaron'], a['Eva'])
a['Jason'].is_son_of(a['James'], a['Rene'])
a['Benito'].is_son_of(a['James'], a['Rene'])

a.compute_factors

a['Ira'].observe_pheno('present')
a['James'].observe_gen('Ff')
a['Rene'].observe_gen('FF')

cpd = a.compute_whole_joint
cpd.marginalize_all_but(a['Benito'].phn)
puts "Probability of Benito showing illness: #{cpd['present']}"

# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7
