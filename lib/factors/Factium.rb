require_relative './Factor'

# Role of a manager of factors.
# Just a collection of factors referenced by injection.
# Holds utility methods and algorithms applicable to sets of factors.

module Factium
  private
  attr_writer :factors
  public
  attr_reader :factors

  def factors
    @factors ||= []
  end

  # Returns the reduction by multiplication with optional normalization
  def product(normalize=true)
    f0 = factors.first.to_ones
    factors.each do |f|
      f0*f
      f0.norm if normalize
    end
    return f0
  end

  # Variable Elimination Algorithm: modifies factors in place and returns tau
  def eliminate_variable!(v)
    tau = nil
    factors.delete_if do |f|
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
      factors.push(tau)
    end
    return tau
  end

end
