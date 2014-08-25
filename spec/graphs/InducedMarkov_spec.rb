describe InducedMarkov do
  
  let(:v1){RandomVar.new(2,"v1")}
  let(:v2){RandomVar.new(2,"v2")}
  let(:v3){RandomVar.new(2,"v3")}
  let(:v4){RandomVar.new(3,"v4")}
  let(:a){Factor.new(v1, [0.11, 0.89])}
  let(:b){Factor.new([v2, v1], [0.59, 0.41, 0.22, 0.78])}
  let(:c){Factor.new([v3, v2, v4], [0.25, 0.35, 0.08, 0.16, 0.05, 
                                    0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])}

  context "#initialize" do

    context "with no factors" do
      it {expect{new([])}.to raise_error}
      it {expect{new}.to raise_error}
    end
    
    context "with valid input factors" do
      it "understands splattered inputs" do
        expect {InducedMarkov.new(a,b,c)}.not_to raise_error
      end
      it "understands array input" do
        expect {InducedMarkov.new([a,b,c])}.not_to raise_error
      end
    end

    context "when creating nodes" do
      subject {InducedMarkov.new(a,b,c)}
      let(:h){h = {}; subject.nodes.each{|n| h[*n.vars] ||= n}; h}

      it "creates one node per variable" do 
        expect(subject.nodes.size).to eq(4)
      end
      it "each node has a different variable" do
        expect(h.size).to eq(4)
        expect(h.keys.uniq.size).to eq(4)
      end
      it "two nodes connect if their vars were together in an input factor" do
        expect(h[v1].edges).to include(h[v2])
        expect(h[v2].edges).to include(h[v1])

        expect(h[v2].edges).to include(h[v3])
        expect(h[v2].edges).to include(h[v4])
        expect(h[v3].edges).to include(h[v2])
        expect(h[v3].edges).to include(h[v4])
        expect(h[v4].edges).to include(h[v2])
        expect(h[v4].edges).to include(h[v3])
      end
    end
  end
end