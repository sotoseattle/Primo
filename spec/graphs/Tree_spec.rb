describe "Tree Role" do
  let(:dummy_class) { Class.new { include Tree } }
  
  let(:v1){RandomVar.new(2, "v1")}
  let(:v2){RandomVar.new(3, "v2")}
  let(:v3){RandomVar.new(2, "v3")}
  let(:v4){RandomVar.new(2, "v4")}
  
  subject {dummy_class.new}

  context "#prune_tree" do
    context "when in terms of variables, no node is a subset of another" do
      it "does nothing" do
        n1 = subject.add_node(v1)
        n2 = subject.add_node(v2)
        n3 = subject.add_node(v3)
        subject.add_edges(n1,n2)
        subject.add_edges(n2,n3)
        
        expect {subject.prune_tree}.not_to change {subject.nodes.size}
      end
    end
    context "when a node's variables are a subset of another node" do
      it "case (ABC)--(BC)--(D) => (ABC)--(D)" do
        n1 = subject.add_node(v1,v2,v3)
        n2 = subject.add_node(v2,v3)
        n3 = subject.add_node(v4)
        subject.add_edges(n1,n2)
        subject.add_edges(n2,n3)
        expect{subject.prune_tree}.to change{subject.nodes.size}.by(-1)
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
        expect{subject.prune_tree}.to change{subject.nodes.size}.by(-2)
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
        expect{subject.prune_tree}.to change{subject.nodes.size}.by(-2)
        expect(subject.nodes.first.vars.size).to eq(3)
        expect(subject.nodes.first.vars).to include(v1,v2,v3)
        expect(subject.nodes.last.vars.size).to eq(1)
        expect(subject.nodes.last.vars).to include(v4)
      end
    end
  end
end
