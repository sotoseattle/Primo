# Induced Markov Network is an undirected graph where each node holds a
# single random variable. It can be created from a set of factors where
# two nodes become connected if the variables they hold show up together
# in a factor.
class InducedMarkov
  include Graph

  private

  attr_writer :factors

  public

  attr_reader :factors

  def initialize(*bunch_o_factors)
    @factors = Array(bunch_o_factors.flatten)
    fail ArgumentError.new if factors.empty?
    h = {}
    factors.each do |f|
      to_connect = []
      f.vars.each do |v|
        h[v] ||= add_node(v)
        to_connect << h[v]
      end
      make_clique(to_connect)
    end
  end
end
