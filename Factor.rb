require 'rubygems'
require 'set'
require 'narray'

require_relative 'RandomVar'

class Factor

  attr_reader :vars, :vals, :cards

  def initialize(variables, arr=nil)
    @vars = Array(variables)
    @cards = @vars.map{|e| e.card}
    arr ? load_vals(arr) : reset_vals
        
    raise ArgumentError.new() if @vars.empty?
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

  def normalize!(cumsum=nil)
    cumsum ||= @vals.flatten.sum
    @vals = @vals/cumsum
    self
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

  def multiply!(other, norma=true)
    return self unless other
    all_vars = [*@vars, *other.vars].uniq.sort
    
    narr1, narr2 = self.expand_axes(all_vars), other.expand_axes(all_vars)
    na = narr1*narr2
    suma  = na.sum

    @vars = all_vars
    @cards = @vars.map{|e| e.card}
    @vals = na.reshape!(*@cards)

    normalize!(suma) if norma
    self
  end

  def add!(other, norma=true)
    all_vars = [*@vars, *other.vars].uniq.sort
    narr1, narr2 = self.expand_axes(all_vars), other.expand_axes(all_vars)
    
    na = narr1+narr2
    suma = na.sum
    
    @vars = all_vars
    @cards = @vars.map{|e| e.card}
    @vals = na.reshape!(*@cards)
    
    normalize!(suma) if norma
    self
  end

  def marginalize!(variable)
    raise ArgumentError.new() unless variable.class<=RandomVar
    new_vars = @vars.reject{|e| e==variable}
    unless new_vars.empty?
      axis_to_marginalize = @vars.index(variable)
      @vars = new_vars
      @cards = @vars.map{|e| e.card}
      @vals = @vals.sum(axis_to_marginalize)
    end
    self
  end

  def marginalize_all_but!(variable)
    raise ArgumentError.new() unless variable.class<=RandomVar
    axis_to_keep = @vars.index(variable)
    if axis_to_keep
      axes_to_remove = [*(0...@vars.size)].reject{|e| e==axis_to_keep}
      axes_to_remove.each_with_index do |axis, i|
        @vals = @vals.sum(axis-i)
      end
      @vars = [variable]
      @cards = [variable.card]
    end
    self
  end

  def reduce!(evidence, norma=true)
    @vars.each_with_index do |rv, i|
      if evidence.has_key?(rv)
        rv.ass.each_with_index do |as, j|
          if as!=evidence[rv]
            temp = [true]*@vars.size
            temp[i] = j
            @vals[*temp] = 0.0
          end
        end
      end
    end
    normalize!() if norma
    self
  end


  def to_s
    "Factor: [#{@vars.map{|e| e.id}.join(', ')}]"
  end
  
end
