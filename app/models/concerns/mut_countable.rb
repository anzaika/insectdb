module MutCountable
  extend ActiveSupport::Concern

  def pn_ps(method: 'ermakova')
    MutationCount::Routine
      .new(segment: self, method: 'ermakova')
      .pn_ps
  end

  def dn_ds(method: 'ermakova')
    MutationCount::Routine
      .new(segment: self, method: 'ermakova')
      .dn_ds
  end

  def alpha
    p = pn_ps
    d = dn_ds
    1 - ((d.s*p.n)/(d.n*p.s))
  end

  module ClassMethods
    def alpha_for(segments)

      p = pll_pn_ps_for(segments)
      puts p.inspect

      reconnect
      d = pll_dn_ds_for(segments)
      puts d.inspect

      reconnect
      1 - ((d.s*p.n)/(d.n*p.s))
    end

    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end

    def pll_pn_ps_for(segments)
      map = (0...(segments.count)).to_a
      Parallel
        .map(map, :in_processes => 8){|i| segments[i].pn_ps}
        .reduce(:+)
    end

    def pll_dn_ds_for(segments)
      map = (0...(segments.count)).to_a
      Parallel
        .map(map, :in_processes => 8){|i| segments[i].dn_ds}
        .reduce(:+)
    end

  end

end
