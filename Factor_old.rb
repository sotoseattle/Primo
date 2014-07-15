require 'rubygems'
require 'set'
require 'narray'

require_relative 'RandomVar'

class Factor

  attr_reader :vars, :vals

  def initialize(variables, arr=nil)
    @vars = Array(variables)
    @cards = @vars.map{|e| e.card}
    @dim = @vars.size
    arr ? load_vals(arr) : reset_vals
        
    raise ArgumentError.new() if @vars.empty?
    raise ArgumentError.new() if @vars.uniq.size!=@dim
    raise ArgumentError.new() unless @vars.all?{|e| e.class<=RandomVar}
  end

  def [](assignments)
    indices = []
    Array(assignments).each_with_index{|s,i| indices << @vars[i].ass.index(s)}
    return @vals[*indices]
  end

  def load_vals(arr)  # fill values matrix from array data
    @vals = NArray.to_na(arr).reshape!(*@cards)
  end

  def reset_vals
    @vals = NArray.float(*@cards)
  end

  def normalize(cumsum=nil)
    cumsum ||= @vals.flatten.sum
    @vals = @vals/cumsum
  end

  def expand_axes(whole_vars)
    return @vals.flatten if @vars==whole_vars

    multiplier = 1.0
    new_vars = whole_vars.reject{|rv| @vars.include?(rv)}

    old_order_vars = [*@vars, *new_vars]
    new_order = whole_vars.map{|e| old_order_vars.index(e)}

    new_cards = new_vars.map{|v| multiplier *= v.card; v.card}
      
    flat = [@vals.flatten] * multiplier
    na = NArray.to_na(flat).reshape!(*@cards, *new_cards)

    if new_order != [*(0..whole_vars.size)]
      na = na.transpose(*new_order)
    end

    return na.flatten
  end

  def multiply(other, norma=true)
    return self unless other
    all_vars = [*@vars, *other.vars].uniq.sort
    
    narr1 = self.expand_axes(all_vars)
    narr2 = other.expand_axes(all_vars)

    na = narr1*narr2
    f = Factor.new(all_vars, na)
    f.normalize(na.cumsum) if norma
    return f
  end

  def add(other, norma=true)
    all_vars = [*@vars, *other.vars].uniq.sort
    
    narr1 = self.expand_axes(all_vars)
    narr2 = other.expand_axes(all_vars)
    
    na = narr1+narr2
    f = Factor.new(all_vars, na)
    f.normalize(na.cumsum) if norma
    return f
  end

  def marginalize(variable)
    raise ArgumentError.new() unless variable.class<=RandomVar
    new_vars = @vars.reject{|e| e==variable}
    f = if new_vars.empty?
      self
    else
      axis_to_marginalize = @vars.index(variable)
      na = @vals.sum(axis_to_marginalize).flatten
      Factor.new(new_vars, na)
    end
    
    return f
  end

  def marginalize_all_but(variable)
    raise ArgumentError.new() unless variable.class<=RandomVar

    axis_to_keep = @vars.index(variable)
    if axis_to_keep
      na = @vals.refer
      axes_to_remove = [*(0...@dim)].reject{|e| e==axis_to_keep}
      axes_to_remove.each_with_index do |axis, i|
        na = na.sum(axis-i)
      end
      f = Factor.new(variable, na)
    else
      f = self
    end

    return f
  end

  def reduce(evidence, norma=true)
    na = @vals.refer
    @vars.each_with_index do |rv, i|
      if evidence.has_key?(rv)
        rv.ass.each_with_index do |as, j|
          if as!=evidence[rv]
            temp = [true]*@dim
            temp[i] = j
            na[*temp] = 0.0
          end
        end
      end
    end
    f = Factor.new(@vars, na)
    f.normalize() if norma
    return f
  end


  def to_s
    "Factor: [#{@vars.map{|e| e.id}.join(', ')}]"
  end
  
end
