describe RandomVar  do
	
	context "#initialize" do
		
		it "with only a single possible value" do
			expect RandomVar.new(1,1).card == 1
		end

		it "with multiple possible values" do
			expect RandomVar.new(1,2).card == 2
			expect RandomVar.new(1,10).card == 10
		end

		it "with no possible value (cardinality zero)" do
			expect{RandomVar.new(1,0)}.to raise_error
		end

	end
end