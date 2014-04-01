require 'sidekiq/api'

module MutCountable
  extend ActiveSupport::Concern

  def pn_ps(method: 'ermakova', **params)
    MutationCount::Routine
      .new(segment: self, method: method)
      .pn_ps(params)
  end

  def dn_ds(method: 'ermakova')
    MutationCount::Routine
      .new(segment: self, method: method)
      .dn_ds
  end

  def norm(method: 'ermakova')
    MutationCount::Routine
      .new(segment: self, method: method)
      .norm
  end

  def alpha
    p = pn_ps
    d = dn_ds
    1 - ((d.s*p.n)/(d.n*p.s))
  end

  module ClassMethods

    def alpha_for(segments, **snp_params)
      alpha_processor(segments, **snp_params)
    end

    def alpha_processor(segments, **snp_params)
      reconnect
      p = pll_pn_ps_for(segments, snp_params)

      reconnect
      d = pll_dn_ds_for(segments)

      reconnect
      n = pll_norm(segments)

      dnn = d.n/n.n
      dsn = d.s/n.s

      pnn = p.n/n.n
      psn = p.s/n.s

      reconnect
      alpha = (1 - ((dsn*pnn)/(dnn*psn))).round(4)

      {
        pnn: pnn.round(4),
        pn: p.n,
        psn: psn.round(4),
        ps: p.s,
        dnn: dnn.round(4),
        dn: d.n,
        dsn: dsn.round(4),
        ds: d.s,
        ns: (n.s).round(0),
        nn: (n.n).round(0),
        alpha: alpha,
        snps: segments.map{|s| s.snps(snp_params).count}.reduce(:+),
        divs: segments.map{|s| s.divs.count}.reduce(:+)
      }
    end

    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end

    def pll_pn_ps_for(segments, snp_params)
      r = Redis.new
      puts hash_name = Random.rand(20000000000).to_s
      segments.each do |s|
        PnPsWorker.perform_async(s.id, hash_name, snp_params)
      end

      while Sidekiq::Stats.new.enqueued != 0 do
        sleep 1
      end

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      # r.flushall
      result
    end

    # def pll_pn_ps_for(segments, snp_params)

    #   Parallel
    #     .map(map, :in_processes => 8){|i| reconnect; segments[i].pn_ps(snp_params)}
    #     .reduce(:+)
    # end

    def pll_dn_ds_for(segments)
      r = Redis.new
      puts hash_name = Random.rand(20000000000).to_s
      segments.each do |s|
        DnDsWorker.perform_async(s.id, hash_name)
      end

      while Sidekiq::Stats.new.enqueued != 0 do
        sleep 1
      end

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      # r.flushall
      result
    end

    # def pll_dn_ds_for(segments)
    #   map = (0...(segments.count)).to_a
    #   Parallel
    #     .map(map, :in_processes => 8){|i| reconnect; segments[i].dn_ds}
    #     .reduce(:+)
    # end

    def pll_norm(segments)
      r = Redis.new
      puts hash_name = Random.rand(20000000000).to_s
      segments.each do |s|
        NormWorker.perform_async(s.id, hash_name)
      end

      while Sidekiq::Stats.new.enqueued != 0 do
        sleep 1
      end

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      # r.flushall
      result
    end

    # def pll_norm(segments)
    #   map = (0...(segments.count)).to_a
    #   pre =
    #     Parallel
    #       .map(map, :in_processes => 8){|i| reconnect; segments[i].norm}
    # end

  end

end
