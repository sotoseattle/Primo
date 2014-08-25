describe "Factium Role" do
  let(:v1){RandomVar.new(2,"v1")}
  let(:v2){RandomVar.new(2,"v2")}
  let(:v3){RandomVar.new(2,"v3")}
  let(:v4){RandomVar.new(3,"v4")}
  let(:a){Factor.new(v1, [0.11, 0.89])}
  let(:b){Factor.new([v2, v1], [0.59, 0.41, 0.22, 0.78])}
  let(:c){Factor.new([v3, v2, v4], [0.25, 0.35, 0.08, 0.16, 0.05, 
                                    0.07, 0, 0, 0.15, 0.21, 0.09, 0.18])}
  let(:d){Factor.new(v2, [0.22, 0.78])}
  let(:dummy_class) { Class.new { include Factium } }
  subject(:ff) {dummy_class.new}
  
  context "#initialize" do
    it {is_expected.to respond_to(:factors)}
    its(:factors) {is_expected.to be_empty}
  end

  
  context "#product" do
    before(:each) {[a,b,c,d].each{|f| ff.factors.push(f)}}
    it "with splattered factors" do
      expect(ff.product(false).vals).to eq((a * b * c * d).vals)
    end
  end

  context "#eliminate_variable!" do
    before(:each) {[a,b,c,d].each{|f| ff.factors.push(f)}}
    context "if variable not in scope" do
      it "don't change anything" do
        expect {ff.eliminate_variable!(RandomVar.new(56))}.not_to change{ff}
      end
      it "return a nil tau" do
        expect(ff.eliminate_variable!(RandomVar.new(56))).to be_nil
      end
    end
    it "reduces the number of factors" do
      expect {ff.eliminate_variable!(v2)}.to change{ff.factors.size}.by(-2)
      expect(ff.factors.size).to eq(2)
    end
    it "remove the variable from all factors" do
      ff.eliminate_variable!(v2)
      expect(ff.factors.first.vars).not_to include v2
      expect(ff.factors.last.vars).not_to  include v2
    end
  end

end