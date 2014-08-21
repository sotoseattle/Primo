require 'rubygems'
require 'benchmark'

require 'pp'
require 'ap'
require '../../CliqueTree'

# CYSTIC FIBROSIS BAYESIAN NETWORK
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations


class Phenotype < RandomVar
  def initialize(id, name)
    super(id, 2, "#{name}_ph", ['present', 'absent'])
  end
end

class Genotype < RandomVar
  def initialize(id, name)
    super(id, 3, "#{name}_gn", ['FF', 'Ff', 'ff'])
  end
end


class Person
  attr_reader :id, :name, :genotype, :phenotype, :f_phenotype, :f_genotype, :parent_1, :parent_2

  # <============= REFACTOR the ID (fugly, there has to be another way)

  def initialize(id, name)
    @name = name
    @phenotype = Phenotype.new(id, name)
    @genotype = Genotype.new(id+1, name)
    @f_phenotype = Factor.new([@phenotype, @genotype], [0.8, 0.2, 0.6, 0.4, 0.1, 0.9])
    @f_genotype = Factor.new([@genotype], [0.01, 0.18, 0.81])
  end
  
  def is_son_of(parent_1, parent_2)
    @parent_1, @parent_2 = parent_1, parent_2
    na = [1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0, 0.0, 0.5, 
          0.5, 0.0, 0.25, 0.5, 0.25, 0.0, 0.5, 0.5, 0.0, 1.0, 
          0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0]
    @f_genotype = Factor.new([@genotype, @parent_1.genotype, @parent_2.genotype], na)
  end
  
  def observe(ass, var_type)
    rv = instance_variable_get("@#{var_type}")
    f = instance_variable_get("@f_#{var_type}")
    f = f.reduce({rv=> ass}).norm
  end
end

class Family
  attr_reader :members, :clique_tree

  def initialize(names)
    @clique_tree = nil
    @members = []
    i = 0
    names.each do |name|
      @members << Person.new(i, name)
      i +=2
    end
  end
  
  def [](name)
    @members.find{|p| p.name==name}
  end

  def setup
    all_factors = @members.map{|p| [p.f_phenotype, p.f_genotype]}.flatten
    @clique_tree = CliqueTree.new(all_factors)
    @clique_tree.calibrate()
  end

  def query(name, var_type)
    rv = self[name].instance_variable_get("@#{var_type}")
    b = @clique_tree.betas.find{|b| b.vars.include?(rv)}
    b.marginalize_all_but(rv)
    b = b.norm.vals.to_a
    sol = {}
    rv.card.times do |i|
      sol[rv.ass[i]]=b[i]
    end
    return sol
  end
end

####################################################################
#########################   TESTING   ##############################
####################################################################

a = Family.new(%w{Ira Robin Aaron Rene James Eva Sandra Jason Benito})# Pepe Juan Margarita})

a['James'].is_son_of(a['Ira'], a['Robin'])
a['Eva'].is_son_of(a['Ira'], a['Robin'])
a['Sandra'].is_son_of(a['Aaron'], a['Eva'])
a['Jason'].is_son_of(a['James'], a['Rene'])
a['Benito'].is_son_of(a['James'], a['Rene'])

#a['Pepe'].is_son_of(a['James'], a['Sandra'])
#a['Juan'].is_son_of(a['Aaron'], a['Eva'])
#a['Margarita'].is_son_of(a['Juan'], a['Pepe'])

a['Ira'].observe('present', 'phenotype')
a['James'].observe('Ff', 'genotype')
a['Rene'].observe('FF', 'genotype')

a.setup()

%w{Ira Robin Aaron Rene James Eva Sandra Jason Benito}.each do |name|
  q = a.query(name, 'phenotype')
  puts "#{name} p(showing illness) = #{100*q['present']}%"
end


# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7





