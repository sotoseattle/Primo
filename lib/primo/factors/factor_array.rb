class FactorArray < Array
  def product(normalize = true)
    wip_factor = first.to_ones
    each do |f|
      wip_factor * f
      wip_factor.norm if normalize
    end
    wip_factor
  end

  def all_vars
    map(&:vars).flatten
  end

  def eliminate_variable!(v)
    tau = nil
    delete_if do |f|
      if f.holds?(v)
        tau ? (tau * f).norm : tau = f
      end
    end
    self << (tau % v) if tau
    tau
  end
end
