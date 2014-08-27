describe RandomVar  do
  context "#initialize" do
    it "with only a single possible value" do
      expect(RandomVar.new({card:1}).card).to eq(1)
    end
    it "with multiple possible values" do
      expect(RandomVar.new({:card=>10}).card).to eq(10)
    end
    it "raises error with cardinality zero" do
      expect{RandomVar.new()}.to raise_error
    end
    it "raises error with no cardinality" do
      expect{RandomVar.new({name:"pepe"})}.to raise_error
    end
    it "raises error if number of assignments is not cardinality" do
    	expect{RandomVar.new({card:10, name:"pepe", ass:[1,2,3]})}.to raise_error
    end
  end
end