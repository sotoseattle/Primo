describe FactorArray do
  let(:v1) { RandomVar.new(card: 2, name: 'v1') }
  let(:v2) { RandomVar.new(card: 2, name: 'v2') }
  let(:v3) { RandomVar.new(card: 2, name: 'v3') }
  let(:v4) { RandomVar.new(card: 3, name: 'v4') }
  let(:a) { Factor.new(vars: [v1], vals: [0.11, 0.89]) }
  let(:b) { Factor.new(vars: [v2, v1], vals: [0.59, 0.41, 0.22, 0.78]) }
  let(:c)do
    Factor.new(vars: [v3, v2, v4],
               vals: [0.25, 0.35, 0.08, 0.16, 0.05, 0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])
  end
  let(:d) { Factor.new(vars: [v2], vals: [0.22, 0.78]) }
  subject(:ff) { FactorArray.new([a, b, c, d]) }

  context 'initialize' do
    it 'is just an Array with extra methods' do
      expect(ff).to be_kind_of(Array)
    end

    it 'cannot be initialized with splattered elements' do
      expect { FactorArray.new(a, b, c, d) }.to raise_error
    end
  end

  context '#product' do
    it 'returns the cum product of the elements' do
      expect(ff.product(false).vals).to eq((a * b * c * d).vals)
    end

    it 'does not modify any elements in place' do
      expect { ff.product(false) }.not_to change { ff }
    end

    it 'the default behavior is to normalize after each product' do
      expect(ff.product.vals).to eq(((((a * b).norm * c).norm * d).norm).vals)
    end

    it 'with normalize=false it does not normalize ever' do
      expect(ff.product(false).vals).to eq((a * b * c * d).vals)
    end
  end

  context '#eliminate_variable!' do
    context 'if variable not in scope' do
      let(:x) { RandomVar.new(card: 56) }

      it "don't change anything" do
        expect { ff.eliminate_variable!(x) }.not_to change { ff }
      end

      it 'return a nil tau' do
        expect(ff.eliminate_variable!(x)).to be_nil
      end
    end

    it 'returns the tau factor fruit of variable elimination algorithm' do
      tau = ff.eliminate_variable!(v2)
      expect(tau).to be_kind_of(Factor)
      expect(tau.vars).not_to include(v2)
    end

    it 'reduces the number of factors in itself' do
      expect { ff.eliminate_variable!(v2) }.to change { ff.size }.by(-2)
      expect(ff.size).to eq(2)
    end

    it 'removes the variable from all surviving factors' do
      ff.eliminate_variable!(v2)
      expect(ff.first.vars).not_to include v2
      expect(ff.last.vars).not_to include v2
    end
  end
end
