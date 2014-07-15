require 'rubygems'
require 'benchmark'
require 'pp'
require './Factor.rb'


v1 = RandomVar.new(1, 3)
v2 = RandomVar.new(2, 2)
v3 = RandomVar.new(3, 2)
v4 = RandomVar.new(4, 2)
v5 = RandomVar.new(5, 3)
v6 = RandomVar.new(6, 3)
v7 = RandomVar.new(7, 2)
v8 = RandomVar.new(8, 3)
 
f1 = Factor.new([v1], [1.0/3.0, 1.0/3.0, 1.0/3.0])
f2 = Factor.new([v8, v2], [0.9, 0.1, 0.5, 0.5, 0.1, 0.9])
f3 = Factor.new([v3, v4, v7, v2], [0.9, 0.1, 0.8, 0.2, 0.7, 0.3, 0.6, 0.4, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8, 0.1, 0.9])
f4 = Factor.new([v4], [0.5, 0.5])
f5 = Factor.new([v5, v6], [0.75, 0.2, 0.05, 0.2, 0.6, 0.2, 0.05, 0.2, 0.75])
f6 = Factor.new([v6], [0.3333, 0.3333, 0.3333])
f7 = Factor.new([v7, v5, v6], [0.9, 0.1, 0.8, 0.2, 0.7, 0.3, 0.6, 0.4, 0.5, 0.5, 0.4, 0.6, 0.3, 0.7, 0.2, 0.8, 0.1, 0.9])
f8 = Factor.new([v8, v4, v1], [0.1, 0.3, 0.6, 0.05, 0.2,0.75, 0.2, 0.5, 0.3, 0.1, 0.35, 0.55, 0.8, 0.15, 0.05, 0.2, 0.6, 0.2])


a = f1.clone
puts Benchmark.measure {
	[f2, f3, f4, f5, f6, f7, f8].each do |f|
 		a = a.multiply(f)
	end
}

[v2,v3,v4,v5,v6,v7,v8].each do |v|
   a = a.marginalize(v)
end

left = a.vals
pp left

right = NArray.to_na([0.37414966, 0.30272109, 0.32312925])
