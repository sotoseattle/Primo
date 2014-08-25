describe "Graphium Role" do
  let(:dummy_class) { Class.new { include Graphium } }
  
  let(:v1){RandomVar.new(2, "v1")}
  let(:v2){RandomVar.new(3, "v2")}
  let(:v3){RandomVar.new(2, "v3")}
  let(:v4){RandomVar.new(2, "v4")}

  let(:n1){Node.new(v1, v2)}
  let(:n2){Node.new(v1, v3)}
  let(:n3){Node.new(v4)}
  
  subject {dummy_class.new}

  context "#nodes" do
    it {is_expected.to respond_to(:nodes)}
    its(:nodes) {is_expected.to be_empty}
  end

  context "#add_node" do
    it "creates and holds reference to a node made of variables" do
      expect {subject.add_node(v1, v2)}.to change {subject.nodes.size}.by(1)
    end
    it "returns the node created" do
      whats_up = subject.add_node(v1)
      expect(whats_up).to be_kind_of Node
    end
  end

  context "#add_edges" do
    it "creates edges between two nodes" do
      subject.add_edges(n1, n2)
      expect(n1.edges).to include(n2)
      expect(n2.edges).to include(n1)
    end

    it {is_expected.to respond_to(:make_clique)}

    it "admits nodes inside array" do
      n4 = subject.add_node(v4)
      subject.add_edges([n1, n2, n3, n4])
      [n1, n2, n3, n4].each do |n|
        expect(n.edges.size).to eq(3)
      end
    end

    it "creates all edges possible among all nodes passed" do
      subject.add_edges(n1, n2, n3)
      expect(n1.edges).to include(n2)
      expect(n1.edges).to include(n3)
      expect(n2.edges).to include(n1)
      expect(n2.edges).to include(n3)
      expect(n3.edges).to include(n1)
      expect(n3.edges).to include(n2)
    end
  end

  context "#loneliest_node" do
    it "returns the node with least connected nodes" do
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      n1 = subject.add_node(v1)
      n4 = subject.add_node(v4)
      subject.add_edges(n1,n2)
      subject.make_clique(n2,n3,n4)
      expect(subject.loneliest_node).to eq(n1)
    end
    it "chooses the first one of two similarly connected nodes" do
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      n1 = subject.add_node(v1)
      subject.add_edges(n1,n2)
      subject.add_edges(n2,n3)
      expect(subject.loneliest_node).to eq(n1)
    end
    it "ignores unlinked nodes if it exists" do
      n1 = subject.add_node(v1)
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      subject.add_edges(n2,n3)
      expect(subject.loneliest_node).not_to eq(n1)
    end
  end

  context "#thinnest_node" do
    it "returns the node with lowest cardinality" do
      n1 = subject.add_node(v1,v2) # card 6
      n2 = subject.add_node(v1,v3) # card 4
      expect(subject.thinnest_node).to eq(n2)
    end
  end

  context "#link_all_with" do
    it "a variable in common" do
      n1 = subject.add_node(v1,v2)
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3,v2)
      n4 = subject.add_node(v4)

      subject.link_all_with(v2)
      expect(n1.edges).to include(n2)
      expect(n1.edges).to include(n3)
      expect(n3.edges).to include(n1)
      expect(n1.edges).not_to include(n4)
      expect(n4.edges).to be_empty
    end
  end

  context "#disconnect" do
    # see spec for Node for better test
    it "removes all edges from a node" do
      n1 = subject.add_node(v1)
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      subject.add_edges(n1,n2)
      subject.add_edges(n2,n3)

      subject.disconnect(n2)
      expect(n2.edges).to be_empty
    end
  end

  context "#prune" do
    context "when in terms of variables, no node is a subset of another" do
      it "does nothing" do
        n1 = subject.add_node(v1)
        n2 = subject.add_node(v2)
        n3 = subject.add_node(v3)
        subject.add_edges(n1,n2)
        subject.add_edges(n2,n3)
        
        expect {subject.prune}.not_to change {subject.nodes.size}
      end
    end
    context "when a node's variables are a subset of another node" do
      it "case (ABC)--(BC)--(D) => (ABC)--(D)" do
        n1 = subject.add_node(v1,v2,v3)
        n2 = subject.add_node(v2,v3)
        n3 = subject.add_node(v4)
        subject.add_edges(n1,n2)
        subject.add_edges(n2,n3)
        expect{subject.prune}.to change{subject.nodes.size}.by(-1)
        expect(subject.nodes.first.vars.size).to eq(3)
        expect(subject.nodes.first.vars).to include(v1,v2,v3)
        expect(subject.nodes.last.vars.size).to eq(1)
        expect(subject.nodes.last.vars).to include(v4)
      end
      it "case (ABC)--(BC)--(C) => (ABC)" do
        n1 = subject.add_node(v1,v2,v3)
        n2 = subject.add_node(v2,v3)
        n3 = subject.add_node(v3)
        subject.add_edges(n1,n2)
        subject.add_edges(n2,n3)
        expect{subject.prune}.to change{subject.nodes.size}.by(-2)
        expect(subject.nodes.first.vars.size).to eq(3)
        expect(subject.nodes.first.vars).to include(v1,v2,v3)
      end
      it "case (ABC)--(BC)--(D) & (ABC)--(AB)--(D) => (ABC)--(D)" do
        n1 = subject.add_node(v1,v2,v3)
        n2 = subject.add_node(v2,v3)
        n3 = subject.add_node(v1,v2)
        n4 = subject.add_node(v4)
        subject.add_edges(n1,n2)
        subject.add_edges(n1,n3)
        subject.add_edges(n2,n4)
        subject.add_edges(n3,n4)
        expect{subject.prune}.to change{subject.nodes.size}.by(-2)
        expect(subject.nodes.first.vars.size).to eq(3)
        expect(subject.nodes.first.vars).to include(v1,v2,v3)
        expect(subject.nodes.last.vars.size).to eq(1)
        expect(subject.nodes.last.vars).to include(v4)
      end
    end
  end

  context "#get_superset" do
    it "returns [] if no matching node found" do
      v5 = RandomVar.new(67,"pepe")
      expect(subject.get_superset([v5])).to be_empty
    end
    it "returns the matching nodes in descending order of size" do
      n1 = subject.add_node(v1,v2,v3)
      n2 = subject.add_node(v2,v3)
      n3 = subject.add_node(v1,v2,v3,v4)
      n4 = subject.add_node(v2,v4)
      
      expect(subject.get_superset([v3])).to eq([n2,n1,n3])
      expect(subject.get_superset([v2]).size).to eq(4)
      expect(subject.get_superset([v1])).to eq([n1,n3])
      expect(subject.get_superset([v4,v2])).to eq([n4,n3])
      expect(subject.get_superset([v2,v4])).to eq([n4,n3])
      expect(subject.get_superset([v1,v2,v3])).to eq([n1,n3])
      expect(subject.get_superset([v1,v2,v3,v4])).to eq([n3])
    end
  end
end



