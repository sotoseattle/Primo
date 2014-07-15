# CYSTIC FIBROSIS BAYESIAN NETWORK
# computed as a whole joint probability factor of ALL variables
# very brutish and primitive but helps test and benchmark factor operations

require 'rubygems'
require 'pp'

require_relative '../../Factor'

class Phenotype < RandomVar
	def initialize(id, name)
		super(id, 2, name, ['present', 'absent'])
	end
end

class Genotype < RandomVar
	def initialize(id, name)
		super(id, 3, name, ['FF', 'Ff', 'ff'])
	end
end


class Person
	attr_reader :id, :name, :gen, :phn, :factor, :dad, :mom

	PHENO_STATS = {'FF'=>0.8, 'Ff'=>0.6, 'ff'=>0.1}
	GEN_STATS = {'F'=>0.1, 'f'=>0.9}

	def initialize(id, name)
		@name = name
		@phn = Phenotype.new(id, name)
		@gen = Genotype.new(id+1, name)
	end

	def is_son_of(dad, mom)
		@dad, @mom = dad, mom
	end

	def compute_factors
		@factor = phen_probabistic(PHENO_STATS)
		if @dad and @mom
			@factor.multiply!(gen_parental)
		else
			@factor.multiply!(gen_probabilistic(GEN_STATS))
		end
	end

	def phen_mendelian
		return phen_probabistic({'FF'=>1.0, 'Ff'=>1.0, 'ff'=>0.0})
	end

	def phen_probabistic(stats)
		values = @gen.ass.map{|g| [stats[g], 1-stats[g]]}
		return Factor.new([@phn, @gen], values)
	end

	# VERY FUGLY AND COUPLED
	# REFACTOR AND GENERALIZE ALL GEN_
	def gen_probabilistic(stats)
		combis = ['F', 'f'].product(['F', 'f']).map{|e| e.sort.join}
		values = @gen.ass.map do |k|
			combis.count(k)*(stats[k[0]]*stats[k[1]])
		end
		return Factor.new([@gen], values)
	end
	def gen_parental
		na = NArray.float(3,3,3)
		@dad.gen.ass.each_with_index do |dad_gen, i|
			@mom.gen.ass.each_with_index do |mom_gen, j|
				d, m = dad_gen.split(''), mom_gen.split('')
				combinations = d.product(m).map{|e| e.sort.join}
				na[true,i,j] = @gen.ass.map{|k| combinations.count(k)/4.0}
			end
		end
		return Factor.new([@gen, @dad.gen, @mom.gen], na)
	end

	def observe_pheno(ass)
		@factor.reduce!({@phn => ass}, true)
	end
	def observe_gen(ass)
		@factor.reduce!({@gen => ass}, true)
	end
end

class Family
	attr_reader :members

	def initialize(names)
		@members = []
		i = 0
		names.each do |name|
			@members << Person.new(i, name)
			i +=2
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

a = Family.new(%w{Ira Robin Aaron Rene James Eva Sandra Jason Benito})


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
cpd.marginalize_all_but!(a['Benito'].phn)
puts "Probability of Benito showing illness: #{cpd['present']}"

# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7


