
describe CliqueTree  do
  
  context "#initialize" do
    let(:v1){RandomVar.new(2,"v1")}
    let(:v2){RandomVar.new(2,"v2")}
    let(:v3){RandomVar.new(2,"v3")}
    let(:v4){RandomVar.new(3,"v4")}
    let(:a){Factor.new(v1, [0.11, 0.89])}
    let(:b){Factor.new([v2, v1], [0.59, 0.41, 0.22, 0.78])}
    let(:c){Factor.new([v3, v2, v4], [0.25, 0.35, 0.08, 0.16, 0.05, 
                                      0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])}
    subject {CliqueTree.new(a,b,c)}
    it {expect{CliqueTree.new(a,b,c)}.not_to raise_error}
    it {is_expected.to respond_to(:nodes)}
    it {is_expected.to respond_to(:factors)}
    xit "the node's bag holds potentials, deltas and betas" do
      subject.nodes.each do |n|
        expect(n.bag.keys).to include(:phi, :delta, :beta)
      end
    end
    it "every node has a valid potential" do
      subject.nodes.each do |n|
        expect(n.bag[:phi].class).to eq(Factor)
        expect(n.bag[:phi].vars).to include(*n.vars)
      end
    end
  end

  context "#generate_tree I" do
    it "creates simple tree" do
      v1 = RandomVar.new(2,"v1")
      v2 = RandomVar.new(2,"v2")
      v3 = RandomVar.new(2,"v3")
      v4 = RandomVar.new(3,"v4")
      a = Factor.new(v1)
      b = Factor.new([v2, v1])
      c = Factor.new([v3, v2, v4])
      ct = CliqueTree.new(a)

      tree = ct.send(:generate_tree,[a,b,c])
      
      expect(tree[0].vars).to include(v2,v1)
      expect(tree[1].vars).to include(v2,v3,v4)
      expect(tree[2].vars).to include(v2,v4)
      expect(tree[0].edges).to include(tree[2])
      expect(tree[1].edges).to include(tree[2])
      expect(tree[2].edges).to include(tree[0],tree[0])
    end

    it "creates complex genetic example tree" do
      names = %w{dad mom kid}
      g, p = {}, {}
      names.each do |name| 
        g[:"#{name}"] = RandomVar.new(3, "#{name}_g")
        p[:"#{name}"] = RandomVar.new(2, "#{name}_p")
      end
      ff = []
      names.each do |name|
        ff << Factor.new([p[:"#{name}"], g[:"#{name}"]])
      end
      %w{dad mom}.each do |name|
        ff << Factor.new([g[:"#{name}"]])
      end
      ff << Factor.new([g[:kid], g[:dad], g[:mom]])
      
      ct = CliqueTree.new(*ff)
      puts ct
    end

    it "creates complex genetic example tree" do
      names = %w{Robin Ira Rene James Eve Aaron Jason Benito Sandra}
      g, p = {}, {}
      names.each do |name| 
        g[:"#{name}"] = RandomVar.new(3, "g_#{name}")
        p[:"#{name}"] = RandomVar.new(2, "p_#{name}")
      end
      ff = []
      names.each do |name|
        ff << Factor.new([p[:"#{name}"], g[:"#{name}"]])
      end
      %w{Robin Ira Rene Aaron}.each do |name|
        ff << Factor.new([g[:"#{name}"]])
      end
      ff << Factor.new([g[:James], g[:Robin], g[:Ira]])
      ff << Factor.new([g[:Eve], g[:Robin], g[:Ira]])
      ff << Factor.new([g[:Jason], g[:Rene], g[:James]])
      ff << Factor.new([g[:Benito], g[:Rene], g[:James]])
      ff << Factor.new([g[:Sandra], g[:Eve], g[:Aaron]])
      
      # ct = CliqueTree.new(Factor.new(RandomVar.new(1)))
      # tree = ct.send(:generate_tree,ff)
      ct = CliqueTree.new(*ff)
      puts ct.nodes.first.bag[:phi].vals.to_a
      # ct.calibrate
      
      # ct.send(:check_coherence)
    end
  end

  # context "#generate_tree II" do
  #   g = (0..9).map{|i| RandomVar.new(3, "g#{i}")}
  #   p = (0..9).map{|i| RandomVar.new(2, "p#{i}")}
  #   puts g.join("-")
  #   puts p.join("-")
    
  #   let(:a){Factor.new(v[0])}
  #   let(:b){Factor.new([v[1], v[0]])}
  #   let(:c){Factor.new([v[2], v[1], v[3]]}


  #   subject {CliqueTree.new(a,b,c)}
  #   before(:each) do
  #     copies_f = [a.clone, b.clone, c.clone]
  #     @ct = CliqueTree.new(a,b,c)
  #     @ct.send(:nodes=, [])    # resetting nodes
  #     @ct.send(:generate_tree)
  #   end
  #   it "just works" do
  #     expect(@ct.nodes[0].vars).to include(v[1],v[0])
  #     expect(@ct.nodes[1].vars).to include(v[1],v[2],v[3])
  #     expect(@ct.nodes[2].vars).to include(v[1],v[3])
  #     expect(@ct.nodes[0].edges).to include(@ct.nodes[2])
  #     expect(@ct.nodes[1].edges).to include(@ct.nodes[2])
  #     expect(@ct.nodes[2].edges).to include(@ct.nodes[0],@ct.nodes[0])
  #   end
  # end

  context "#compute_delta"   do
    xit "xxx" do
      ct = CliqueTree.new(a,b,c)
      ct.calibrate
      ct.send(:check_coherence)
    end
  end



end
