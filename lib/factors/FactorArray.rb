require_relative './Factor'

# Just a collection of factors referenced by injection.
# Holds utility methods and algorithms applicable to sets of factors.

class FactorArray < Array
  
  # Returns the reduction by multiplication with optional normalization
  def product(normalize=true)
    f0 = first.to_ones
    self.each do |f|
      f0*f
      f0.norm if normalize
    end
    return f0
  end

  def all_vars
    map{|f| f.vars}.flatten
  end

  # Variable Elimination Algorithm: modifies factors in place and returns tau
  def eliminate_variable!(v)
    tau = nil
    delete_if do |f|
      if f.holds?(v)
        if tau
          (tau*f).norm
        else
          tau = f
        end
      end
    end
    if tau
      tau % v
      self.push(tau)
    end
    return tau
  end

end
