require 'narray'

class Factor
  attr_accessor :vars, :vals

  def initialize(args)
    args.merge(vals: nil)
    @vars = Array(args[:vars])

    @vals = if args[:vals]
              NArray[args[:vals]].reshape!(*cardinalities)
            else
              NArray.float(*cardinalities)
            end

    fail ArgumentError if @vars.any? { |e| !e.is_a?(RandomVar) }
  end

  def cardinalities(array_of_variables = vars)
    array_of_variables.map(&:card)
  end

  def assignment_index(random_variable, assignment)
    random_variable.[](assignment)
  end

  def [](assignments)
    indices = Array(assignments).each_with_index.map do |s, i|
      assignment_index(vars[i], s)
    end
    vals[*indices]
  end

  [:*, :+].each do |o|
    define_method(o) do |other|
      other.is_a?(Numeric) ? self.vals = vals.send(o, other) : modify_by(other, &o)
      self
    end
  end

  def modify_by(other)
    return self unless other

    all_vars = [*vars, *other.vars].uniq.sort
    new_narray = yield(grow_axes(all_vars), other.grow_axes(all_vars))

    self.vars = all_vars
    self.vals = new_narray.reshape!(*cardinalities)
    self
  end

  def marginalize(variable)
    axis_to_marginalize = vars.index(variable)
    if axis_to_marginalize && vars.size > 1
      vars.delete_at(axis_to_marginalize)
      self.vals = vals.sum(axis_to_marginalize)
    end
    self
  end
  alias_method :%, :marginalize

  def marginalize_all_but(variable)
    fail ArgumentError unless (axis_to_keep = vars.index(variable))

    axes_to_remove = [*(0...vars.size)].reject { |x| x == axis_to_keep }
    axes_to_remove.each_with_index { |axis, i| self.vals = vals.sum(axis - i) }
    self.vars = [variable]
    self
  end

  def reduce(evidence)
    observed_index = vars.map do |rv|
      evidence.key?(rv) ? assignment_index(rv, evidence[rv]) : true
    end
    zeroes = NArray.float(*vals.shape)
    zeroes[*observed_index] = vals[*observed_index]
    self.vals = zeroes
    self
  end

  def normalize_values
    cumulative_sum = vals.sum(*(0...vars.size))
    self.vals /= cumulative_sum
    self
  end
  alias_method :norm, :normalize_values

  def to_s
    "Factor: [#{vars.map(&:name).join(', ')}]"
  end

  def holds?(variable)
    vars.include?(variable)
  end

  def to_ones
    Factor.new(vars: vars) + 1.0
  end

  def clone
    Factor.new(vars: vars.dup, vals: vals.dup)
  end

  # prior to *,+ both factors need to be of equal dimensions
  # this complicated method grows extra dimensions (axis) according to var map,
  # copying in the new higher dimensions the values from lower dimensions
  def grow_axes(whole_vars)
    return vals.flatten if vars == whole_vars

    multiplier = 1.0
    new_vars = whole_vars.reject { |rv| vars.include?(rv) }

    old_order_vars = [*vars, *new_vars]
    new_order = whole_vars.map { |e| old_order_vars.index(e) }

    new_cards = cardinalities(new_vars)
    multiplier = new_cards.reduce(multiplier, :*)

    flat = [vals.flatten] * multiplier
    na = NArray.to_na(flat).reshape!(*vals.shape, *new_cards)

    na = na.transpose(*new_order) if new_order != [*(0..whole_vars.size)]

    na.flatten
  end
end
