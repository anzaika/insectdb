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

  def norm
    MutationCount::Routine
      .new(segment: self, method: 'ermakova')
      .norm
  end

  def alpha
    p = pn_ps
    d = dn_ds
    1 - ((d.s*p.n)/(d.n*p.s))
  end

  module ClassMethods
    def alpha_for(segments)

      reconnect
      p = pll_pn_ps_for(segments)
      puts 'pn_ps before norm:'
      puts p.inspect

      reconnect
      d = pll_dn_ds_for(segments)
      puts 'dn_ds before norm:'
      puts d.inspect

      reconnect
      n = pll_norm_for(segments)
      puts 'norm:'
      puts n.inspect

      d.n = d.n/n.n
      d.s = d.s/n.s

      p.n = p.n/n.n
      p.s = p.s/n.s

      reconnect
      alpha = (1 - ((d.s*p.n)/(d.n*p.s))).round(4)
      puts "| #{p.n} | #{p.s} | #{d.n} | #{d.s} | #{alpha} |"
    end

    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end

    def pll_pn_ps_for(segments)
      map = (0...(segments.count)).to_a
      Parallel
        .map(map, :in_processes => 8){|i| reconnect; segments[i].pn_ps}
        .reduce(:+)
    end

    def pll_dn_ds_for(segments)
      map = (0...(segments.count)).to_a
      Parallel
        .map(map, :in_processes => 8){|i| reconnect; segments[i].dn_ds}
        .reduce(:+)
    end

    def pll_norm_for(segments)
      map = (0...(segments.count)).to_a
      pre =
        Parallel
          .map(map, :in_processes => 8){|i| reconnect; segments[i].norm}
      puts "nils in norm: #{pre.count{|n| n.nil?}}"
      pre.compact.reduce(:+)
    end

  end

end
