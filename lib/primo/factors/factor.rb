require 'narray'
class Factor
  private

  attr_writer :vars, :vals

  public

  attr_reader :vars, :vals

  def initialize(args)
    args.merge(vals: nil)
    @vars = Array(args[:vars])
    @vals = if args[:vals]
              NArray[args[:vals]].reshape!(*cardinalities)
    else
      NArray.float(*cardinalities)
    end
    fail ArgumentError.new if @vars.empty?
    fail ArgumentError.new unless @vars.all? { |e| e.class <= RandomVar }
  end

  # isolation ward for calls to RandomVar methods (poodr)
  def cardinalities(variable_arr = vars)
    variable_arr.map(&:card)
  end

  def assignment_index(rv, assignment)
    rv.ass.index(assignment)
  end

  # utility function for results over a CPD
  def [](assignments)
    indices = Array(assignments).each_with_index.map do |s, i|
      assignment_index(vars[i], s)
    end
    vals[*indices]
  end

  # basic operation on two factors (*,+). Resulting factor overwrites caller
  def modify_in_place(other, &_block)
    return self unless other
    all_vars = [*vars, *other.vars].uniq.sort.reverse

    narr1 = grow_axes(all_vars)
    narr2 = other.grow_axes(all_vars)
    na = yield narr1, narr2

    self.vars = all_vars
    self.vals = na.reshape!(*cardinalities)
    self
  end

  def *(other)
    if other.is_a? Numeric
      self.vals = vals * other
    else
      modify_in_place(other, &:*)
    end
    self
  end

  def +(other)
    if other.is_a? Numeric
      self.vals = vals + other
    else
      modify_in_place(other, &:+)
    end
    self
  end

  # normalize values so it adds up to 1
  def norm
    cumsum = vals.sum(*(0...vars.size))
    self.vals = vals / cumsum
    self
  end

  # eliminates a dimension / variable by adding along its axis
  # allows for chaining operations i.e. f1 % v1 % v2
  def marginalize(variable)
    axis_to_marginalize = vars.index(variable)
    if axis_to_marginalize && vars.size > 1
      vars.delete_at(axis_to_marginalize)
      self.vals = vals.sum(axis_to_marginalize)
    end
    self
  end
  alias_method :%, :marginalize

  # a faster implementation for a bulk operation
  def marginalize_all_but(variable)
    axis_to_keep = vars.index(variable)
    fail ArgumentError.new unless axis_to_keep
    axes_to_remove = [*(0...vars.size)].reject { |e| e == axis_to_keep }
    axes_to_remove.each_with_index do |axis, i|
      self.vals = vals.sum(axis - i)
    end
    self.vars = [variable]
    self
  end

  # set values to 0.0 based on observed variables
  # i.e. if we know color is red, then p(blue)=0.0
  def reduce(evidence)
    observed_index = vars.map do |rv|
      evidence.key?(rv) ? assignment_index(rv, evidence[rv]) : true
    end
    zeroes = NArray.float(*vals.shape)
    zeroes[*observed_index] = vals[*observed_index]
    self.vals = zeroes
    self
  end

  def to_s
    # "Factor: [#{vars.map{|e| e.id}.join(', ')}]"
    "Factor: [#{vars.map(&:name).join(', ')}]"
  end

  def holds?(variable)
    vars.include?(variable)
  end

  # Returns a copy with same vars but all values to 1.0
  def to_ones
    (Factor.new(vars: vars) + 1.0)
  end

  def clone
    Factor.new(vars: vars.dup, vals: vals.dup)
  end

  protected

  # prior to *,+ both factors need to be of equal dimensions
  # this complicated method grows extra dimensions (axis) according to
  # var map, copy-pasting in higher dims the values from lower dimensions
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

    if new_order != [*(0..whole_vars.size)]
      na = na.transpose(*new_order)
    end

    na.flatten
  end
end
