# CYSTIC FIBROSIS BAYESIAN NETWORK DECOUPLED
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations

require 'rubygems'
require 'pp'

require_relative '../../Factor'

class PhenoType < RandomVar
	def initialize(id, name)
		super(id, 2, name, ['present', 'absent'])
	end
end

class AlleleType < RandomVar
	def initialize(id, name)
		super(id, 3, name, ['F', 'f', 'n'])
	end
end


class Person
	attr_reader :id, :name, :allel_1, :allel_2, :pheno, :factor, :dad, :mom

	#ALLELES_STATS = {'F'=>0.1, 'f'=>0.7, 'n'=>0.2}

	def initialize(id, name)
		@name = name
		@pheno = PhenoType.new(id, name)
		@allel_1 = AlleleType.new(id+1, name)
		@allel_2 = AlleleType.new(id+2, name)
	end

	def is_son_of(dad, mom)
		@dad, @mom = dad, mom
	end

	def alleles_factors_probabilistic
		f1 = Factor.new(@allel_1, [0.1, 0.7, 0.2])
		f2 = Factor.new(@allel_2, [0.1, 0.7, 0.2])
		f1.multiply!(f2)
	end

	def alleles_factors_genetic
		vals = [1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.5, 0.0, 0.5, 0.5, 0.0, 0.0, 1.0]
		f1 = Factor.new([@allel_1, @dad.allel_1, @dad.allel_2], vals)
		f2 = Factor.new([@allel_2, @mom.allel_1, @mom.allel_2], vals)
		f1.multiply!(f2)
	end

	def phenotype_factor
		vars = [@pheno, @allel_1, @allel_2]
		vals = [0.8, 0.2, 0.6, 0.4, 0.1, 0.9, 0.6, 0.4, 0.5, 0.5, 0.05, 0.95, 0.1, 0.9, 0.05, 0.95, 0.01, 0.99]
		return Factor.new(vars, vals)
	end

	def compute_factors
		@factor = phenotype_factor
		if (@dad and @mom)
			@factor.multiply!(alleles_factors_genetic)
		else
			@factor.multiply!(alleles_factors_probabilistic)
		end
	end

	def observe_pheno(ass)
		@factor.reduce!({@pheno => ass}, true)
	end
	def observe_gens(ass)
		@factor.reduce!({@allel_1 => ass[0]}, true).reduce!({@allel_2 => ass[1]}, true)
	end
end

class Family
	attr_reader :members

	def initialize(names)
		@members = []
		i = 0
		names.each do |name|
			@members << Person.new(i, name)
			i +=3
		end
	end

	def compute_factors
		@members.each{|p| p.compute_factors}
	end

	def compute_whole_joint
		f = @members[0].factor.clone
		(1...@members.size).each{|i| f.multiply!(@members[i].factor)}
		return f
	end

	def [](name)
		@members.find{|p| p.name==name}
	end
	
end

####################################################################
#########################   TESTING   ##############################
####################################################################
# Beware, adding Sandra makes the joint CPD so huge that it blows 
# a segmentation bug because the resulting NArray is too big

#a = Family.new(%w{Ira Robin Aaron Rene James Eva Sandra Jason Benito})
#a = Family.new(%w{Ira Robin Rene James Eva Benito Sandra})
a = Family.new(%w{Ira Robin Rene James Eva Benito})

a['James'].is_son_of(a['Ira'], a['Robin'])
a['Eva'].is_son_of(a['Ira'], a['Robin'])
#a['Sandra'].is_son_of(a['Aaron'], a['Eva'])
#a['Jason'].is_son_of(a['James'], a['Rene'])
a['Benito'].is_son_of(a['James'], a['Rene'])

a.compute_factors

a['Ira'].observe_pheno('present')
a['Rene'].observe_gens(['F','f'])
a['Eva'].observe_pheno('present')

Benito_pheno = a.compute_whole_joint.marginalize_all_but!(a['Benito'].pheno)
puts "Probability of Benito showing illness: #{Benito_pheno['present']}"

# no reductions      => P(Benito ill present) == 0.3554
# only Ira reduction => P(Benito ill present) == 0.39008
# all reductions     => P(Benito ill present) == 0.54095


