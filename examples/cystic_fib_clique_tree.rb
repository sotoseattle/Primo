# GENETIC BAYESIAN NETWORK III
# computed with a clique tree, fast and reliable, scales very well

require 'primo'
require './vars.rb'
require './family.rb'

class Person
  attr_accessor :name, :geno, :phen, :f_phen, :f_geno, :parent_1, :parent_2

  def initialize(name)
    @name = name
    @phen = Phenotype.new(name)
    @geno = Genotype.new(name)
    @f_phen = Factor.new(vars: [phen, geno], vals: [0.8, 0.2, 0.6, 0.4, 0.1, 0.9])
    @f_geno = Factor.new(vars: [geno], vals: [0.01, 0.18, 0.81])
  end

  def son_of(parent_1, parent_2)
    @f_geno = Factor.new(vars: [geno, parent_1.geno, parent_2.geno],
                         vals: Genotype::HardCodedValues)
  end

  def observe(ass, var_type)
    random_var = instance_variable_get("@#{var_type}")
    factor = instance_variable_get("@f_#{var_type}")
    factor.reduce(random_var => ass).normalize_values
  end
end

class CTFamily < Family
  attr_accessor :clique_tree

  def setup
    all_factors = members.map { |person| [person.f_phen, person.f_geno] }.flatten
    @clique_tree = CliqueTree.new(*all_factors)
    clique_tree.calibrate
  end

  def prob_sick(name)
    random_var = self[name].phen
    100 * clique_tree.query(random_var, 'present')
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################

smiths = CTFamily.new(%w(Ira Robin Aaron Rene James Eva Sandra Jason
                         Benito Pepe Juan Margarita))

smiths['James'].son_of(smiths['Ira'], smiths['Robin'])
smiths['Eva'].son_of(smiths['Ira'], smiths['Robin'])
smiths['Sandra'].son_of(smiths['Aaron'], smiths['Eva'])
smiths['Jason'].son_of(smiths['James'], smiths['Rene'])
smiths['Benito'].son_of(smiths['James'], smiths['Rene'])

smiths['Pepe'].son_of(smiths['James'], smiths['Sandra'])
smiths['Juan'].son_of(smiths['Aaron'], smiths['Eva'])
smiths['Margarita'].son_of(smiths['Juan'], smiths['Pepe'])

smiths['Ira'].observe('present', 'phen')
smiths['James'].observe('Ff', 'geno')
smiths['Rene'].observe('FF', 'geno')

smiths.setup

%w(Ira Robin Aaron Rene James Eva Sandra Jason Benito).each do |name|
  puts "#{name} p(showing illness) = #{smiths.prob_sick(name)}%"
end

# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7
