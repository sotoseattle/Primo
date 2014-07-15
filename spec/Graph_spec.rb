require 'rubygems'
require 'spec_helper'
require "rspec"



describe "Graph"  do
  describe "#initialize" do
    let(:v1){RandomVar.new(1,2)}
    let(:v2){RandomVar.new(2,3)}

  	describe "works" do
    	it "without arguments" do
      	expect{u = Graph.new()}.not_to raise_error
      	expect{u.nodes.empty? == true}
      	expect{u.total==0}
      end
      it "with a single var" do
        expect{u = Graph.new([v1])}.not_to raise_error
      end
    end
  end
end