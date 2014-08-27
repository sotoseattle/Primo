describe "Graph Role" do
  let(:dummy_class) { Class.new { include Graph } }
  
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

  context "#add_neighbors" do
    it "creates edges between two nodes" do
      subject.add_neighbors(n1, n2)
      expect(n1.neighbors).to include(n2)
      expect(n2.neighbors).to include(n1)
    end

    it {is_expected.to respond_to(:make_clique)}

    it "admits nodes inside array" do
      n4 = subject.add_node(v4)
      subject.add_neighbors([n1, n2, n3, n4])
      [n1, n2, n3, n4].each do |n|
        expect(n.neighbors.size).to eq(3)
      end
    end

    it "creates all edges possible among all nodes passed" do
      subject.add_neighbors(n1, n2, n3)
      expect(n1.neighbors).to include(n2)
      expect(n1.neighbors).to include(n3)
      expect(n2.neighbors).to include(n1)
      expect(n2.neighbors).to include(n3)
      expect(n3.neighbors).to include(n1)
      expect(n3.neighbors).to include(n2)
    end
  end

  context "#sort_by_neighbors" do
    it "returns nodes from least to most connected" do
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      n1 = subject.add_node(v1)
      n4 = subject.add_node(v4)
      subject.add_neighbors(n1,n2)
      subject.make_clique(n2,n3,n4)
      expect(subject.sort_by_neighbors.first).to eq(n1)
    end
  end

  context "#loneliest_node" do
    it "returns the node with least connected nodes" do
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      n1 = subject.add_node(v1)
      n4 = subject.add_node(v4)
      subject.add_neighbors(n1,n2)
      subject.make_clique(n2,n3,n4)
      expect(subject.loneliest_node).to eq(n1)
    end
    it "chooses the first one of two similarly connected nodes" do
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      n1 = subject.add_node(v1)
      subject.add_neighbors(n1,n2)
      subject.add_neighbors(n2,n3)
      expect(subject.loneliest_node).to eq(n1)
    end
    it "does not ignores unlinked nodes if they exists" do
      n1 = subject.add_node(v1)
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      subject.add_neighbors(n2,n3)
      expect(subject.loneliest_node).to eq(n1)
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
      expect(n1.neighbors).to include(n2)
      expect(n1.neighbors).to include(n3)
      expect(n3.neighbors).to include(n1)
      expect(n1.neighbors).not_to include(n4)
      expect(n4.neighbors).to be_empty
    end
  end

  context "#disconnect" do
    # see spec for Node for better test
    it "removes all neighbors from a node" do
      n1 = subject.add_node(v1)
      n2 = subject.add_node(v2)
      n3 = subject.add_node(v3)
      subject.add_neighbors(n1,n2)
      subject.add_neighbors(n2,n3)

      subject.disconnect(n2)
      expect(n2.neighbors).to be_empty
    end
  end

  # context "#get_superset" do
  #   it "returns [] if no matching node found" do
  #     v5 = RandomVar.new(67,"pepe")
  #     expect(subject.get_superset([v5])).to be_empty
  #   end
  #   it "returns the matching nodes in descending order of size" do
  #     n1 = subject.add_node(v1,v2,v3)
  #     n2 = subject.add_node(v2,v3)
  #     n3 = subject.add_node(v1,v2,v3,v4)
  #     n4 = subject.add_node(v2,v4)
      
  #     expect(subject.get_superset([v3])).to eq([n2,n1,n3])
  #     expect(subject.get_superset([v2]).size).to eq(4)
  #     expect(subject.get_superset([v1])).to eq([n1,n3])
  #     expect(subject.get_superset([v4,v2])).to eq([n4,n3])
  #     expect(subject.get_superset([v2,v4])).to eq([n4,n3])
  #     expect(subject.get_superset([v1,v2,v3])).to eq([n1,n3])
  #     expect(subject.get_superset([v1,v2,v3,v4])).to eq([n3])
  #   end
  # end

  context "#breadth_first_search_path" do
    context "returns an ordered path that visits all nodes" do
      let(:g){subject}
      let(:path) {g.breadth_first_search_path(g.nodes[4])}
      before do
        (0...6).each{|i| g.add_node(RandomVar.new(2, "v#{i}"))}
        g.link_between(g.nodes[0], [g.nodes[1],g.nodes[2],g.nodes[5]])
        g.link_between(g.nodes[2], [g.nodes[3],g.nodes[4]])
      end
      it "visits all nodes of the graph" do
        expect(path.size).to eq(6)
      end    
      it "ordered in visiting order" do
        expect(path).to eq([4,2,0,3,1,5].map{|i| g.nodes[i]})
      end
    end
  end
end



