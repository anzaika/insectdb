# require 'sidekiq/api'

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

  module ClassMethods

    BATCH = 300

    def alpha_for(segments, **snp_params)
      alpha_processor(segments, **snp_params)
    end

    def alpha_processor(segments, **snp_params)

      ids = segments.map(&:id)

      p = pll_pn_ps(ids, snp_params)
      d = pll_dn_ds(ids)
      n = pll_norm(ids)


      dnn = d.n/n.n
      dsn = d.s/n.s

      pnn = p.n/n.n
      psn = p.s/n.s

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

    def pll_pn_ps(ids, snp_params)
      # t = Time.now
      r = Redis.new
      hash_name = Random.rand(20000000000).to_s
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(PnPsWorker, slice, hash_name, snp_params)
      end

      while Resque.size(:mut_count)!= 0 do
        sleep 5
      end

      sleep 18

      # puts 'Done in: ' + (Time.now - t).round(0).to_s + 's'

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      r.flushall
      result
    end

    def pll_dn_ds(ids)
      # t = Time.now
      r = Redis.new
      hash_name = Random.rand(20000000000).to_s
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(DnDsWorker, slice, hash_name)
      end

      while Resque.size(:mut_count)!= 0 do
        sleep 5
      end

      sleep 18

      # puts 'Done in: ' + (Time.now - t).round(0).to_s + 's'

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      r.flushall
      result
    end

    def pll_norm(ids)
      # t = Time.now
      r = Redis.new
      hash_name = Random.rand(20000000000).to_s
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(NormWorker, slice, hash_name)
      end

      while Resque.size(:mut_count)!= 0 do
        sleep 5
      end

      sleep 18

      # puts 'Done in: ' + (Time.now - t).round(0).to_s + 's'

      result = r.hvals(hash_name).map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      r.flushall
      result
    end

  end

end
