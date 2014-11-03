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
    na = [1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5,
          0.5, 0.0, 0.25, 0.5, 0.25, 0.0, 0.5, 0.5, 0.0, 1.0,
          0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0]
    @f_geno = Factor.new(vars: [geno, parent_1.geno, parent_2.geno], vals: na)
  end

  def observe(ass, var_type)
    rv = instance_variable_get("@#{var_type}")
    f = instance_variable_get("@f_#{var_type}")
    f.reduce(rv => ass).norm
  end
end

class CTFamily < Family
  attr_accessor :clique_tree

  def setup
    all_factors = members.map { |p| [p.f_phen, p.f_geno] }.flatten
    self.clique_tree = CliqueTree.new(*all_factors)
    clique_tree.calibrate
  end

  def prob_sick(name)
    rv = self[name].phen
    100 * clique_tree.query(rv, 'present')
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################

a = CTFamily.new(%w(Ira Robin Aaron Rene James Eva Sandra Jason Benito Pepe
                    Juan Margarita))

a['James'].son_of(a['Ira'], a['Robin'])
a['Eva'].son_of(a['Ira'], a['Robin'])
a['Sandra'].son_of(a['Aaron'], a['Eva'])
a['Jason'].son_of(a['James'], a['Rene'])
a['Benito'].son_of(a['James'], a['Rene'])

a['Pepe'].son_of(a['James'], a['Sandra'])
a['Juan'].son_of(a['Aaron'], a['Eva'])
a['Margarita'].son_of(a['Juan'], a['Pepe'])

a['Ira'].observe('present', 'phen')
a['James'].observe('Ff', 'geno')
a['Rene'].observe('FF', 'geno')

a.setup

%w(Ira Robin Aaron Rene James Eva Sandra Jason Benito).each do |name|
  puts "#{name} p(showing illness) = #{a.prob_sick(name)}%"
end

# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7
