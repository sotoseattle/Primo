require 'rubygems'
require 'spec_helper'
require "rspec"

TOL = 1e-10
describe "Factor"  do
  let(:v1){RandomVar.new(1,2)}
  let(:v2){RandomVar.new(2,2)}
  let(:v3){RandomVar.new(3,2)}
  let(:v4){RandomVar.new(4,3)}
  let(:a){Factor.new(v1, [0.11, 0.89])}
  let(:b){Factor.new([v2, v1], [0.59, 0.41, 0.22, 0.78])}
  let(:c){Factor.new([v3, v2], [0.39, 0.61, 0.06, 0.94])}
  let(:x){Factor.new([v2, v4], [0.5, 0.8, 0.1, 0.0, 0.3, 0.9])}
  let(:y){Factor.new([v3, v2], [0.5, 0.7, 0.1, 0.2])}
  let(:z){Factor.new([v3, v2, v4], [0.25, 0.35, 0.08, 0.16, 0.05, 0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])}
  let(:w){Factor.new([RandomVar.new(1, 5), RandomVar.new(7, 2)])}

  describe "when #initialize a factor" do
    
    describe "fails" do
      it "if not given any variables" do
        expect{Factor.new([])}.to raise_error
        expect{Factor.new()}.to raise_error
        expect{Factor.new(nil)}.to raise_error
      end
      it "if given non random variables" do
        expect{Factor.new([3, "foo", RandomVar.new(7, 2)])}.to raise_error
        expect{Factor.new([0])}.to raise_error
      end
    end

    it "it picks the cardinalities from the variables" do
      expect{w.vals.shape == [5, 2]}
    end

    it "when no values given, all to zeros" do
      sol = w.vals.flatten
      expect sol.size==10
      10.times{|i| expect sol[i] == 0.0}
    end
  end

  describe "when we #load_vals a factor" do
    it "we fold an input array according to the shape of the values matrix" do
      w.load_vals([1,2,3,4,5,6,7,8,9,0])

      left = w.vals.to_a
      left[0].should match_array([1, 2, 3, 4, 5])
      left[1].should match_array([6, 7, 8, 9, 0])     

      y = Factor.new([RandomVar.new(1, 2), RandomVar.new(2, 2), 
                      RandomVar.new(3, 3)])
      y.load_vals([1,2,3,4,5,6,7,8,9,10,11,12])
      left = y.vals.to_a
      left[0].should match_array([[1, 2], [3, 4]])
      left[1].should match_array([[5, 6], [7, 8]])
      left[2].should match_array([[9, 10], [11, 12]])
    end
  end

  describe "#multiply" do
    it "when whatever" do
      a.multiply!(b)
      sol = a.vals - NArray.to_na([0.0649, 0.1958, 0.0451, 0.6942]).reshape!(2,2)
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
    it "when whatever 2" do
      v1 = RandomVar.new(1,3)
      v2 = RandomVar.new(2,2)
      v3 = RandomVar.new(3,2)
      x1 = Factor.new([v2, v1], [0.5, 0.8, 0.1, 0.0, 0.3, 0.9])
      y1 = Factor.new([v3, v2], [0.5, 0.7, 0.1, 0.2])
      
      right = NArray.to_na([0.25, 0.05, 0.15, 0.08, 0.0, 0.09, 0.35, 0.07, 0.21, 0.16, 0.0, 0.18]).reshape!(3,2,2)
      sol = x1.multiply!(y1, false).vals - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
  end

  describe "#marginalize" do
    it "whatever 1" do
      b.marginalize!(v2)
      b.vals.flatten.each{|e| e.should be_within(TOL).of(1.0)}
    end
    it "whatever 2" do
      right = NArray.to_na([0.33, 0.51, 0.05, 0.07, 0.24, 0.39]).reshape!(2,3)
      sol = z.marginalize!(v2).vals - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
  end

  describe "#marginalize_all_but" do
    it "whatever 1" do
      left = x.clone.marginalize_all_but!(v2).vals
      right = x.marginalize!(v4).vals
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
    it "whatever 2" do
      left = z.clone.marginalize_all_but!(v3).vals
      right = z.marginalize!(v2)
      right = right.marginalize!(v4).vals
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
  end

  describe "#reduce" do
    it "whatever 1" do
      left = a.clone.reduce!({v2=>0, v3=>1}).vals
      right = a.vals
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
    it "whatever 2" do
      left = b.reduce!({v2=>0, v3=>1}, false).vals
      right = NArray.to_na([0.59, 0.0, 0.22, 0.0]).reshape!(2,2)
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
    it "whatever 3" do
      left = c.reduce!({v2=>0, v3=>1}, false).vals
      right = NArray.to_na([0.0, 0.61, 0.0, 0.0]).reshape!(2,2)
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
    it "whatever 4" do
      left = z.reduce!({v3=>0}, norma=false).vals
      right = NArray.to_na([0.25, 0.0, 0.08, 0.0, 0.05, 0.0, 0.0, 0.0, 0.15, 0.0, 0.09, 0.0]).reshape!(2,2,3)
      sol = left - right
      sol.each{|e| e.should be_within(TOL).of(0.0)}
    end
  end

  describe "cojo tests" do
    it "cojo 1" do
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
      [f2, f3, f4, f5, f6, f7, f8].each{|f| a.multiply!(f)}

      [v2,v3,v4,v5,v6,v7,v8].each{|v| a.marginalize!(v)}

      left = a.vals
      right = NArray.to_na([0.37414966, 0.30272109, 0.32312925])
      sol = left - right
      sol.each{|e| e.should be_within(1e-8).of(0.0)}
    end

    it "cojo 2" do
      v1 = RandomVar.new(1, 2)
      v2 = RandomVar.new(2, 2)
      v3 = RandomVar.new(3, 2)
      v4 = RandomVar.new(4, 3)
      v5 = RandomVar.new(5, 2)
          
      d = Factor.new([v1], [0.6, 0.4])
      i = Factor.new([v2], [0.7, 0.3]);
      s = Factor.new([v3, v2], [0.95, 0.05, 0.2, 0.8]);
      g = Factor.new([v4, v1, v2], [0.3, 0.4, 0.3, 0.05, 0.25, 0.7, 0.9, 0.08, 0.02, 0.5, 0.3, 0.2]);
      l = Factor.new([v5, v4], [0.1, 0.9, 0.4, 0.6, 0.99, 0.01]);
      
      s = s.reduce!({v3=>1}) # we observe high SAT
      
      a = d
      [i, s, g, l].each{|f| a.multiply!(f)}
      [v1, v3, v4, v5].each{|v| a.marginalize!(v)}
    
      a.vals[0].should be_within(1e-8).of(0.12727273)
      a.vals[1].should be_within(1e-8).of(0.87272727)
    end
  end

end












