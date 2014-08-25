
describe CliqueTree  do
  let(:v1){RandomVar.new(2,"v1")}
  let(:v2){RandomVar.new(2,"v2")}
  let(:v3){RandomVar.new(2,"v3")}
  let(:v4){RandomVar.new(3,"v4")}
  let(:a){Factor.new(v1, [0.11, 0.89])}
  let(:b){Factor.new([v2, v1], [0.59, 0.41, 0.22, 0.78])}
  let(:c){Factor.new([v3, v2, v4], [0.25, 0.35, 0.08, 0.16, 0.05, 
                                    0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])}
  subject {CliqueTree.new(a,b,c)}
  context "#initialize" do
    it {expect{CliqueTree.new(a,b,c)}.not_to raise_error}
    it {is_expected.to respond_to(:nodes)}
    it {is_expected.to respond_to(:factors)}
  end

  context "#generate_tree" do
    before(:each) do
      copies_f = [a.clone, b.clone, c.clone]
      @ct = CliqueTree.new(a,b,c)
      @ct.send(:nodes=, [])    # resetting nodes
      @ct.send(:generate_tree)
    end
    it "just works" do
      expect(@ct.nodes[0].vars).to include(v2,v1)
      expect(@ct.nodes[1].vars).to include(v2,v3,v4)
      expect(@ct.nodes[2].vars).to include(v2,v4)
      expect(@ct.nodes[0].edges).to include(@ct.nodes[2])
      expect(@ct.nodes[1].edges).to include(@ct.nodes[2])
      expect(@ct.nodes[2].edges).to include(@ct.nodes[0],@ct.nodes[0])
    end
    it "each node has a :phi set to nil in the bag, and no more" do
      @ct.nodes.each do |n|
        expect(n.bag.size).to eq(1)
        expect(n.bag[:phi]).to be_nil
      end
    end
  end

  context "#initialize_potentials" do
    it "xxx" do
      copies_f = [a.clone, b.clone, c.clone]
      ct = CliqueTree.new(a,b,c)
      ct.send(:factors=, copies_f)  # resetting factors
      puts ct
      ct.send(:initialize_potentials)
      expect(ct.nodes[1].bag[:phi].vals).to eq(c.vals)
    end
  end



end
