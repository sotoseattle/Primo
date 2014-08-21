require 'narray'
require 'set'

require_relative 'RandomVar'

class Factor
  
  private
  attr_accessor :vals, :vars, :cards
  public
  attr_reader :vars, :vals, :cards

  def initialize(variables, arr=nil)
    @vars = Array(variables)
    @cards = @vars.map{|e| e.card}
    @vals = if arr
      NArray.to_na(arr).reshape!(*cards)
    else
      NArray.float(*cards)
    end
    raise ArgumentError.new if @vars.empty?
    raise ArgumentError.new unless @vars.all?{|e| e.class<=RandomVar}
  end


  def [](assignments)
    indices = Array(assignments).each_with_index.map do |s,i| 
      vars[i].ass.index(s)
    end
    return vals[*indices]
  end
  
  def grow_axes(whole_vars)
    return vals.flatten if vars==whole_vars

    multiplier = 1.0
    new_vars = whole_vars.reject{|rv| vars.include?(rv)}

    old_order_vars = [*vars, *new_vars]
    new_order = whole_vars.map{|e| old_order_vars.index(e)}

    new_cards = new_vars.map{|v| multiplier *= v.card; v.card}
      
    flat = [vals.flatten] * multiplier
    na = NArray.to_na(flat).reshape!(*cards, *new_cards)

    if new_order != [*(0..whole_vars.size)]
      na = na.transpose(*new_order)
    end

    return na.flatten
  end

  def *(other)
    modify_in_place(other, &:*)
  end
  def +(other)
    modify_in_place(other, &:+)
  end
  def modify_in_place(other, &block)
    return self unless other
    all_vars = [*vars, *other.vars].uniq.sort

    narr1 = self.grow_axes(all_vars)
    narr2 = other.grow_axes(all_vars)
    na = yield narr1, narr2

    self.vars = all_vars
    self.cards = vars.map{|e| e.card}
    self.vals = na.reshape!(*cards)
    return self
  end

  def norm
    cumsum = vals.sum(*(0...vars.size))
    self.vals = vals/cumsum
    return self
  end

  def marginalize(variable)
    axis_to_marginalize = vars.index(variable)
    if axis_to_marginalize && vars.size>1
      vars.delete_at(axis_to_marginalize)
      cards.delete_at(axis_to_marginalize)
      self.vals = vals.sum(axis_to_marginalize)
    end
    return self
  end
  alias_method :%, :marginalize

  def marginalize_all_but(variable)
    axis_to_keep = vars.index(variable)
    raise ArgumentError.new unless axis_to_keep
    axes_to_remove = [*(0...vars.size)].reject{|e| e==axis_to_keep}
    axes_to_remove.each_with_index do |axis, i|
      self.vals = vals.sum(axis-i)
    end
    vars = [variable]
    cards = [variable.card]
    return self
  end

  def reduce(evidence)
    vars.each_with_index do |rv, i|
      if evidence.has_key?(rv)
        rv.ass.each_with_index do |as, j|
          if as!=evidence[rv]
            temp = [true]*vars.size
            temp[i] = j
            vals[*temp] = 0.0
          end
        end
      end
    end
    return self
  end


  def to_s
    "Factor: [#{vars.map{|e| e.id}.join(', ')}]"
  end
  
end
