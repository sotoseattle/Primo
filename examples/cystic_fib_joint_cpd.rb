# GENETIC BAYESIAN NETWORK I
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations
# Factors are shown hardcoded.

require 'primo'
require './vars.rb'
require './family.rb'

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

  def son_of(daddy, mommy)
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

  def gen_probabilistic(_stats)
    Factor.new(vars: [gen], vals: [0.01, 0.18, 0.81])
  end

  def gen_parental
    vals = [[[1.0, 0.0, 0.0], [0.5, 0.5, 0.0],   [0.0, 1.0, 0.0]],
            [[0.5, 0.5, 0.0], [0.25, 0.5, 0.25], [0.0, 0.5, 0.5]],
            [[0.0, 1.0, 0.0], [0.0, 0.5, 0.5],   [0.0, 0.0, 1.0]]]
    Factor.new(vars: [gen, dad.gen, mom.gen], vals: vals)
  end

  def observe_pheno(ass)
    factor.reduce(phn => ass).norm
  end

  def observe_gen(ass)
    factor.reduce(gen => ass).norm
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################

a = Family.new(%w(Ira Robin Aaron Rene James Eva Sandra Jason Benito))

a['James'].son_of(a['Ira'], a['Robin'])
a['Eva'].son_of(a['Ira'], a['Robin'])
a['Sandra'].son_of(a['Aaron'], a['Eva'])
a['Jason'].son_of(a['James'], a['Rene'])
a['Benito'].son_of(a['James'], a['Rene'])

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
