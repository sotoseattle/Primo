describe Graph  do
  context "#initialize" do
    let(:v1){RandomVar.new(1,2)}
    let(:v2){RandomVar.new(2,3)}

    context "without arguments" do
      it "runs ok" do
    	  expect{subject}.not_to raise_error
        expect(subject.nodes).to be_empty
    	  expect(subject.size).to be_zero
      end
    end
    context "with arguments" do
      it "example I" do
        expect{u = Graph.new([v1])}.not_to raise_error
      end
      it "example II" do
        u = Graph.new([v1, v2])
        expect(u.nodes).to_not be_empty
        expect(u.size).to be == 2
      end
    end
    
  end
end