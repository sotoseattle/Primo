
describe CliqueTree  do

  context '#initialize' do
    let(:v1) { RandomVar.new(card: 2, name: 'v1') }
    let(:v2) { RandomVar.new(card: 2, name: 'v2') }
    let(:v3) { RandomVar.new(card: 2, name: 'v3') }
    let(:v4) { RandomVar.new(card: 3, name: 'v4') }
    let(:a) { Factor.new(vars: [v1], vals: [0.11, 0.89]) }
    let(:b) { Factor.new(vars: [v2, v1], vals: [0.59, 0.41, 0.22, 0.78]) }
    let(:c)do
      Factor.new(vars: [v3, v2, v4], vals: [0.25, 0.35, 0.08, 0.16, 0.05,
                                            0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])
    end
    subject { CliqueTree.new(a, b, c) }
    it { expect { CliqueTree.new(a, b, c) }.not_to raise_error }
    it { is_expected.to respond_to(:nodes) }

    it "the node's bag holds potentials, deltas and betas" do
      subject.nodes.each do |n|
        expect(n.bag.keys).to include(:phi, :beta)
        expect(n).to respond_to(:incoming)
      end
    end
    it 'every node has a valid potential' do
      subject.nodes.each do |n|
        expect(n.bag[:phi].class).to eq(Factor)
        expect(n.bag[:phi].vars).to include(*n.vars)
      end
    end
    it 'creates simple genetic example tree' do
      g, p = {}, {}
      ff = []
      %w(dad mom kid).each do |name|
        g[:"#{name}"] = RandomVar.new(card: 3, name: "#{name}_g")
        p[:"#{name}"] = RandomVar.new(card: 2, name: "#{name}_p")
        ff << Factor.new(vars: [p[:"#{name}"], g[:"#{name}"]])
      end
      ff << Factor.new(vars: [g[:dad]])
      ff << Factor.new(vars: [g[:mom]])
      ff << Factor.new(vars: [g[:kid], g[:dad], g[:mom]])

      ct = CliqueTree.new(*ff)
      sepsets = ct.nodes
      expect(sepsets.size).to eq(4)
      expect(sepsets.last.neighbors).to include(sepsets[0], sepsets[1], sepsets[2])
      sepsets.each do |sepset|
        expect(sepset.bag[:phi].class).to eq(Factor)
        expect(sepset.bag[:phi].vars.sort).to eq(sepset.vars.sort)
        expect(sepset.bag[:beta]).to be_nil
        expect(sepset.bag[:tau]).not_to be
      end
    end
    it 'creates complex genetic example tree' do
      names = %w(Robin Ira Rene James Eve Aaron Jason Benito Sandra)
      g, p = {}, {}
      names.each do |name|
        g[:"#{name}"] = RandomVar.new(card: 3, name: "g_#{name}")
        p[:"#{name}"] = RandomVar.new(card: 2, name: "p_#{name}")
      end
      ff = []
      names.each do |name|
        ff << Factor.new(vars: [p[:"#{name}"], g[:"#{name}"]])
      end
      %w(Robin Ira Rene Aaron).each do |name|
        ff << Factor.new(vars: [g[:"#{name}"]])
      end
      ff << Factor.new(vars: [g[:James], g[:Robin], g[:Ira]])
      ff << Factor.new(vars: [g[:Eve], g[:Robin], g[:Ira]])
      ff << Factor.new(vars: [g[:Jason], g[:Rene], g[:James]])
      ff << Factor.new(vars: [g[:Benito], g[:Rene], g[:James]])
      ff << Factor.new(vars: [g[:Sandra], g[:Eve], g[:Aaron]])

      ct = CliqueTree.new(*ff)
      sepsets = ct.nodes
      expect(sepsets.size).to eq(14)
    end
  end

  context '#generate_tree I' do
    it 'creates simple tree' do
      v1 = RandomVar.new(card: 2, name: 'v1')
      v2 = RandomVar.new(card: 2, name: 'v2')
      v3 = RandomVar.new(card: 2, name: 'v3')
      v4 = RandomVar.new(card: 3, name: 'v4')
      a = Factor.new(vars: [v1])
      b = Factor.new(vars: [v2, v1])
      c = Factor.new(vars: [v3, v2, v4])
      ct = CliqueTree.new(a)
      sepsets = ct.send(:generate_tree, [a, b, c])

      expect(sepsets[0].vars).to include(v2, v1)
      expect(sepsets[1].vars).to include(v2, v3, v4)
      expect(sepsets[2].vars).to include(v3, v4)
      expect(sepsets[0].neighbors).to include(sepsets[1])
      expect(sepsets[1].neighbors).to include(sepsets[0], sepsets[2])
      expect(sepsets[2].neighbors).to include(sepsets[1])
    end
  end

  context '#calibrate' do
    let(:v1) { RandomVar.new(card: 2, name: 'v1') }
    let(:v2) { RandomVar.new(card: 2, name: 'v2') }
    let(:v3) { RandomVar.new(card: 2, name: 'v3') }
    let(:v4) { RandomVar.new(card: 3, name: 'v4') }
    let(:a) { Factor.new(vars: [v1], vals: [0.11, 0.89]) }
    let(:b) { Factor.new(vars: [v2, v1], vals: [0.59, 0.41, 0.22, 0.78]) }
    let(:c)do
      Factor.new(vars: [v3, v2, v4], vals: [0.25, 0.35, 0.08, 0.16, 0.05,
                                            0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])
    end
    let(:d) { Factor.new(vars: [v1, v4], vals: [0.59, 0.41, 0.22, 0.78, 1.0, 1.0]) }

    subject { CliqueTree.new(a, b, c, d) }
    it 'marginals from different betas/nodes give the same probability' do
      subject.calibrate
      subject.nodes.each do |pick_node|
        pick_node.vars.each do |pick_var|
          sepsets = subject.nodes.select { |n| n.vars.include?(pick_var) }
          marginals = sepsets.map do |n|
            marg = n.bag[:beta].clone.marginalize_all_but(pick_var).norm
            marg.vals.to_a
          end
          standard = marginals.pop
          marginals.each_with_index do |m, i|
            expect(m[i]).to be_within(1e-8).of(standard[i])
          end
        end
      end
    end
  end

end
