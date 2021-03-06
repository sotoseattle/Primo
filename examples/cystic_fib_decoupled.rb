# GENETIC BAYESIAN NETWORK II
# computed as a whole joint probability factor of ALL variables, even more
# brutish than before because decoupling means more variables and dimensions
# The factors are hard-coded

require 'primo'
require './vars.rb'
require './family.rb'

class Person
  private

  attr_accessor :factor, :dad, :mom

  public

  attr_reader :name, :allel_1, :allel_2, :pheno, :factor

  def initialize(name)
    @name = name
    @pheno = Phenotype.new(name)
    @allel_1 = AlleleType.new(name)
    @allel_2 = AlleleType.new(name)
  end

  def son_of(daddy, mommy)
    self.dad = daddy
    self.mom = mommy
  end

  def alleles_factors_probabilistic
    Factor.new(vars: [allel_1, allel_2],
               vals: [[0.01, 0.07, 0.02], [0.07, 0.49, 0.14], [0.02, 0.14, 0.04]])
  end

  def alleles_factors_genetic
    vals = Genotype::HardCodedValues
    f1 = Factor.new(vars: [allel_1, dad.allel_1, dad.allel_2], vals: vals)
    f2 = Factor.new(vars: [allel_2, mom.allel_1, mom.allel_2], vals: vals)
    (f1 * f2).normalize_values
  end

  def phenotype_factor
    vars = [pheno, allel_1, allel_2]
    vals = [0.8, 0.2, 0.6, 0.4, 0.1, 0.9, 0.6, 0.4, 0.5, 0.5, 0.05, 0.95, 0.1,
            0.9, 0.05, 0.95, 0.01, 0.99]
    Factor.new(vars: vars, vals: vals)
  end

  def compute_factors
    self.factor = phenotype_factor
    factor * ((dad && mom) ? alleles_factors_genetic : alleles_factors_probabilistic)
    factor.normalize_values
  end

  def observe_pheno(ass)
    factor.reduce(pheno => ass).normalize_values
  end

  def observe_gens(ass)
    factor.reduce(allel_1 => ass[0]).reduce(allel_2 => ass[1]).normalize_values
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################
# Beware, adding another child (Sandra) makes the joint CPD so huge that it blows
# a segmentation error. The resulting NArray is too big

smiths = Family.new(%w(Ira Robin Rene James Eva Benito))

smiths['James'].son_of(smiths['Ira'], smiths['Robin'])
smiths['Eva'].son_of(smiths['Ira'], smiths['Robin'])
smiths['Benito'].son_of(smiths['James'], smiths['Rene'])

smiths.compute_factors

smiths['Ira'].observe_pheno('present')
smiths['Rene'].observe_gens(%w(F f))
smiths['Eva'].observe_pheno('present')

Benito_pheno = smiths.compute_whole_joint
                     .marginalize_all_but(smiths['Benito'].pheno)

puts "Probability of Benito showing illness: #{Benito_pheno['present']}"

# no reductions      => P(Benito ill present) == 0.3554
# only Ira reduction => P(Benito ill present) == 0.39008
# all reductions     => P(Benito ill present) == 0.54095
