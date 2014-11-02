RSpec::Matchers.define :match_each_cell do |expected, tol|
  match do |actual|
    (actual.vals - expected).flatten.to_a.each do |e|
      return false if e.abs > tol
      true
    end
  end
end

describe Factor  do

  TOL = 1e-10

  let(:v1) { RandomVar.new(card: 2, name: 'v1') }
  let(:v2) { RandomVar.new(card: 2, name: 'v2') }
  let(:v3) { RandomVar.new(card: 2, name: 'v3') }
  let(:v4) { RandomVar.new(card: 3, name: 'v4') }
  let(:v5) { RandomVar.new(card: 5, name: 'v5') }
  let(:a) { Factor.new(vars: v1, vals: [0.11, 0.89]) }
  let(:b) { Factor.new(vars: [v2, v1], vals: [0.59, 0.41, 0.22, 0.78]) }
  let(:c)do
    Factor.new(vars: [v3, v2, v4],
               vals: [0.25, 0.35, 0.08, 0.16, 0.05, 0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])
  end
  let(:e) { Factor.new(vars: [v5, v1]) }

  context '#initialize' do
    it 'fails without input variables' do
      expect { Factor.new([]) }.to raise_error
      expect { Factor.new }.to raise_error
      expect { Factor.new(nil) }.to raise_error
    end

    it 'fails with non random variables' do
      expect { Factor.new([3, 'foo', RandomVar.new(card: 2)]) }.to raise_error
      expect { Factor.new([0]) }.to raise_error
    end

    it 'picks the cardinalities from the variables' do
      expect(e.vals.shape).to match [5, 2]
    end

    it 'when no values given, initializes values to zero' do
      expect(e.vals.flatten).to match NArray.float(10)
    end

    context 'fills input array according to the shape of values matrix' do
      it 'example I' do
        f = Factor.new(vars: [v5, v1], vals: [*(1..10)])
        expect(f.vals).to match NArray[1..10].reshape(5, 2)
      end

      it 'example II' do
        y = Factor.new(vars: [v1, v2, v4], vals: [*(1..12)])
        left = y.vals.to_a
        expect(left[0]).to match_array [[1, 2], [3, 4]]
        expect(left[1]).to match_array [[5, 6], [7, 8]]
        expect(left[2]).to match_array [[9, 10], [11, 12]]
      end
    end
  end

  context '#multiplication' do
    it 'by a number, multiplies by number all the vals cells' do
      a * 2
      expect(a).to match_each_cell(NArray[0.22, 1.78], TOL)
    end

    context 'by factor' do
      it 'modifies in place (the first) with product algorithm: I' do
        a * b
        target = if a.__id__ > b.__id__
                   NArray[0.0649, 0.0451, 0.1958, 0.6942]
                 else
                   NArray[0.0649, 0.1958, 0.0451, 0.6942]
                 end
        target.reshape!(2, 2)
        expect(a).to match_each_cell(target, TOL)
      end

      it 'modifies in place (the first) with product algorithm: II' do
        r1 = RandomVar.new(card: 3, name: 'r1')
        r2 = RandomVar.new(card: 2, name: 'r2')
        r3 = RandomVar.new(card: 2, name: 'r3')
        x1 = Factor.new(vars: [r2, r1], vals: [0.5, 0.8, 0.1, 0.0, 0.3, 0.9])
        y1 = Factor.new(vars: [r3, r2], vals: [0.5, 0.7, 0.1, 0.2])
        x1 * y1
        if x1.__id__ < y1.__id__
          target = [[[0.25, 0.05, 0.15], [0.08, 0.0, 0.09]],
                    [[0.35, 0.07, 0.21], [0.16, 0.0, 0.18]]]
          expect(x1).to match_each_cell(target, TOL)
        else
          target = [[[0.25, 0.35], [0.08, 0.16]],
                    [[0.05, 0.07], [0.00, 0.00]],
                    [[0.15, 0.21], [0.09, 0.18]]]
          expect(x1).to match_each_cell(target, TOL)
        end
      end
    end
  end

  context '#addition' do
    it 'by number, adds number to all cells of vals' do
      a + 1.0
      expect(a).to match_each_cell(NArray[1.11, 1.89], TOL)
    end

    it 'by factor, it modifies in place (the first) with addition algorithm' do
      a + b
      if a.__id__ < b.__id__
        target = [[0.7, 1.11], [0.52, 1.67]]
        expect(a).to match_each_cell(target, TOL)
      else
        target = [[0.7, 0.52], [1.11, 1.67]]
        expect(a).to match_each_cell(target, TOL)
      end
    end
  end

  context '#marginalize' do
    it 'returns itself if variable not in factor' do
      target = b.clone.vals
      expect(b % v3).to match_each_cell(target, 0.00)
    end

    it 'returns itself if trying to marginalize the last variable' do
      expect((b % v1 % v2).vars).to match([v2])
    end

    it 'computes correctly the folding axes (I)' do
      expect((b % v2).vals).to be_within(TOL).of(1.0)
    end

    it 'computes correctly the folding axes (II)' do
      target = NArray.to_na([0.33, 0.51, 0.05, 0.07, 0.24, 0.39]).reshape!(2, 3)
      expect((c % v2)).to match_each_cell(target, TOL)
    end
  end

  context '#marginalize_all_but' do
    it 'computes correctly (I)' do
      x = Factor.new(vars: [v2, v4], vals: [0.5, 0.8, 0.1, 0.0, 0.3, 0.9])
      y = x.clone
      expect(y.marginalize_all_but(v2)).to match_each_cell((x % v4).vals, TOL)
    end

    it 'computes correctly (II)' do
      left = c.clone.marginalize_all_but(v3)
      right = ((c % v2) % v4).vals
      expect(left).to match_each_cell(right, TOL)
    end
  end

  context '#reduce' do
    it 'does nothing if vars are not in scope' do
      expect(a.clone.reduce(v2 => 0, v3 => 1)).to match_each_cell(a.vals, TOL)
    end

    it 'works example I' do
      left = b.reduce(v2 => 0, v3 => 1)
      right = NArray.to_na([0.59, 0.0, 0.22, 0.0]).reshape!(2, 2)
      expect(left).to match_each_cell(right, TOL)
    end

    it 'works example II' do
      left = Factor.new(vars: [v3, v2], vals: [0.39, 0.61, 0.06, 0.94])
      left.reduce(v2 => 0, v3 => 1)
      right = NArray.to_na([0.0, 0.61, 0.0, 0.0]).reshape!(2, 2)
      expect(left).to match_each_cell(right, TOL)
    end

    it 'works example III' do
      left = c.reduce(v3 => 0)
      right = NArray.to_na([0.25, 0.0, 0.08, 0.0, 0.05, 0.0, 0.0, 0.0, 0.15,
                            0.0, 0.09, 0.0]).reshape!(2, 2, 3)
      expect(left).to match_each_cell(right, TOL)
    end
  end

  context 'multiple operations integration tests' do
    it 'cojo test I' do
      v1 = RandomVar.new(card: 3, name: 'v1')
      v2 = RandomVar.new(card: 2, name: 'v2')
      v3 = RandomVar.new(card: 2, name: 'v3')
      v4 = RandomVar.new(card: 2, name: 'v4')
      v5 = RandomVar.new(card: 3, name: 'v5')
      v6 = RandomVar.new(card: 3, name: 'v6')
      v7 = RandomVar.new(card: 2, name: 'v7')
      v8 = RandomVar.new(card: 3, name: 'v8')

      f1 = Factor.new(vars: [v1], vals: [1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0])
      f2 = Factor.new(vars: [v8, v2], vals: [0.9, 0.1, 0.5, 0.5, 0.1, 0.9])
      f3 = Factor.new(vars: [v3, v4, v7, v2],
                      vals: [0.9, 0.1, 0.8, 0.2, 0.7, 0.3, 0.6, 0.4,
                             0.4, 0.6, 0.3, 0.7, 0.2, 0.8, 0.1, 0.9])
      f4 = Factor.new(vars: [v4], vals: [0.5, 0.5])
      f5 = Factor.new(vars: [v5, v6],
                      vals: [0.75, 0.2, 0.05, 0.2, 0.6, 0.2, 0.05, 0.2, 0.75])
      f6 = Factor.new(vars: [v6], vals: [0.3333, 0.3333, 0.3333])
      f7 = Factor.new(vars: [v7, v5, v6],
                      vals: [0.9, 0.1, 0.8, 0.2, 0.7, 0.3, 0.6, 0.4, 0.5, 0.5,
                             0.4, 0.6, 0.3, 0.7, 0.2, 0.8, 0.1, 0.9])
      f8 = Factor.new(vars: [v8, v4, v1],
                      vals: [0.1, 0.3, 0.6, 0.05, 0.2, 0.75, 0.2, 0.5, 0.3, 0.1,
                             0.35, 0.55, 0.8, 0.15, 0.05, 0.2, 0.6, 0.2])

      [f1, f2, f3, f4, f5, f6, f7, f8].reduce(:*)
      [v2, v3, v4, v5, v6, v7, v8].each { |v| f1 % v }
      target = NArray.to_na([0.37414966, 0.30272109, 0.32312925])
      expect(f1.norm).to match_each_cell(target, 1e-8)
    end

    it 'cojo test II' do
      v1 = RandomVar.new(card: 2, name: 'v1')
      v2 = RandomVar.new(card: 2, name: 'v2')
      v3 = RandomVar.new(card: 2, name: 'v3')
      v4 = RandomVar.new(card: 3, name: 'v4')
      v5 = RandomVar.new(card: 2, name: 'v5')

      d = Factor.new(vars: [v1], vals: [0.6, 0.4])
      i = Factor.new(vars: [v2], vals: [0.7, 0.3])
      s = Factor.new(vars: [v3, v2], vals: [0.95, 0.05, 0.2, 0.8])
      g = Factor.new(vars: [v4, v1, v2], vals: [0.3, 0.4, 0.3, 0.05, 0.25, 0.7,
                                                0.9, 0.08, 0.02, 0.5, 0.3, 0.2])
      l = Factor.new(vars: [v5, v4], vals: [0.1, 0.9, 0.4, 0.6, 0.99, 0.01])

      s = s.reduce(v3 => 1) # we observe high SAT

      [i, s, g, l].each { |f| (d * f).norm }
      [v1, v3, v4, v5].each { |v| d % v }
      expect(d.vals[0]).to be_within(1e-8).of(0.12727273)
      expect(d.vals[1]).to be_within(1e-8).of(0.87272727)
    end
  end

  context '#to_ones' do
    it 'creates a copy of self with all values equal to 1.0' do
      expect(c.to_ones.vars).to eq(c.vars)
      expect(c.to_ones.vals).to eq((c.vals * 0) + 1.0)
    end
  end

  context '#clone' do
    let(:original) { Factor.new(vars: [v3, v2], vals: [0.95, 0.05, 0.2, 0.8]) }

    it 'makes a copy of the factor' do
      copy = original.clone
      original % v2
      expect(copy.vars).to eq([v3, v2])
      expect(original.vars).to eq([v3])
    end

    it 'changes the object_id of the factor' do
      copy = original.clone
      expect(copy.object_id).not_to eq(original.object_id)
    end

    it 'does not change the object_id of the variables' do
      copy = original.clone
      expect(copy.vars.first.object_id).to eq(original.vars.first.object_id)
    end
  end
end
