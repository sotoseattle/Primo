class InducedMarkov
  include Graph

  private

  attr_writer :factors

  public

  attr_reader :factors

  def initialize(*bunch_o_factors)
    @factors = Array(bunch_o_factors.flatten)
    fail ArgumentError if factors.empty?

    h = {}
    factors.each do |f|
      to_connect = f.vars.reduce([]) { |a, e| a << (h[e] ||= add_node(e)) }
      make_clique(to_connect)
    end
  end
end
