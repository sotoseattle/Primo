describe Node  do
  
  let(:v1){RandomVar.new(2, "v1")}
  let(:v2){RandomVar.new(3, "v2")}
  let(:v3){RandomVar.new(2, "v3")}
  let(:v4){RandomVar.new(2, "v4")}

  context "#initialize" do
    context "without variables" do
      it {expect{Node.new}.to raise_error(ArgumentError)}
    end
    context "with proper variables" do
      subject {Node.new(v1, v2, v2)}
      it {is_expected.to respond_to(:vars)}
      it {is_expected.to respond_to(:edges)}
      it {expect(subject.vars.size).to eq(2)}
      its(:edges) {should be_empty}
    end
    context "with array of variables" do
      it {expect{Node.new([v1, v2, v2])}.not_to raise_error}
    end
  end

  context "#connect" do
    let(:n1){Node.new(v1, v2)}
    let(:n2){Node.new(v1, v3)}
    let(:n3){Node.new(v4)}

    it "should increment the edges array" do
      expect {n1.connect(n2)}.to change {n1.edges.size}.by(1)
    end
    it "should add the node to edges array" do
      n1.connect(n2)
      expect(n1.edges).to include n2
    end
    it "should add itself to the connected node's edges" do
      n1.connect(n2)
      expect(n2.edges).to include n1
    end
    it "should not connect if already connected" do
      n1.connect(n2)
      expect {n1.connect(n2)}.not_to change {n1.edges.size}
    end
    it "should not connect to itself" do
      expect {n1.connect(n1)}.not_to change {n1.edges.size}
    end
  end

  context "#isolate!" do
    let(:n1){Node.new(v1, v2)}
    let(:n2){Node.new(v1, v3)}
    let(:n3){Node.new(v4)}

    it "removes all edges" do
      n1.connect(n2)
      n1.connect(n3)
      expect {n1.isolate!}.to change {n1.edges.size}.by(-2)
      expect(n1.edges).to be_empty
    end
    it "remove itself from the edges of its previously connected nodes" do
      n1.connect(n2)
      n1.connect(n3)
      n2.connect(n3)
      n1.isolate!
      expect(n2.edges).not_to include(n1)
      expect(n3.edges).not_to include(n1)
      expect(n3.edges).to include(n2)
    end

  end

  context "#weight" do
    it "computes the combined product of vars' cardinalities" do
      expect(Node.new(v1, v2).weight).to eq(6)
      expect(Node.new(v1, v3).weight).to eq(4)
      expect(Node.new(v4).weight).to eq(2)
    end
  end

end









