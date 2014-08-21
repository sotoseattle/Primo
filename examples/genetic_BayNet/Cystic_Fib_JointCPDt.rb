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
	private
	attr_accessor :factor, :dad, :mom
	public
	attr_reader :id, :name, :gen, :phn, :factor

	PHENO_STATS = {'FF'=>0.8, 'Ff'=>0.6, 'ff'=>0.1}
	GEN_STATS = {'F'=>0.1, 'f'=>0.9}

	def initialize(id, name)
		@name = name
		@phn = Phenotype.new(id, name)
		@gen = Genotype.new(1000+id, name) # jump of 1,000 to avoid overlap
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

	def phen_mendelian
		return phen_probabistic({'FF'=>1.0, 'Ff'=>1.0, 'ff'=>0.0})
	end

	def phen_probabistic(stats)
		values = gen.ass.map{|g| [stats[g], 1-stats[g]]}
		return Factor.new([phn, gen], values)
	end

	# VERY FUGLY AND COUPLED
	# REFACTOR AND GENERALIZE ALL GEN_
	def gen_probabilistic(stats)
		combis = ['F', 'f'].product(['F', 'f']).map{|e| e.sort.join}
		values = gen.ass.map do |k|
			combis.count(k)*(stats[k[0]]*stats[k[1]])
		end
		return Factor.new([gen], values)
	end
	def gen_parental
		na = NArray.float(3,3,3)
		dad.gen.ass.each_with_index do |dad_gen, i|
			mom.gen.ass.each_with_index do |mom_gen, j|
				d, m = dad_gen.split(''), mom_gen.split('')
				combinations = d.product(m).map{|e| e.sort.join}
				na[true,i,j] = gen.ass.map{|k| combinations.count(k)/4.0}
			end
		end
		return Factor.new([gen, dad.gen, mom.gen], na)
	end

	def observe_pheno(ass)
		factor.reduce({phn => ass}).norm
	end
	def observe_gen(ass)
		factor.reduce({gen => ass}).norm
	end
end

class Family
	attr_reader :members

	def initialize(names)
		@members = names.each_with_index.map{|name,i| Person.new(i, name)}
	end

	def compute_factors
		members.each{|p| p.compute_factors}
	end

	def compute_whole_joint
		a = members.first.factor
		return members[1..-1].reduce(a){|a,b| (a*b.factor).norm}
	end

	def [](name)
		members.find{|p| p.name==name}
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
cpd.marginalize_all_but(a['Benito'].phn)
puts "Probability of Benito showing illness: #{cpd['present']}"

# no reductions      => P(Benito ill present) == 0.197
# only Ira reduction => P(Benito ill present) == 0.2474593908629386
# all reductions     => P(Benito ill present) == 0.7


