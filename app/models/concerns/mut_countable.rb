# require 'sidekiq/api'

module MutCountable
  extend ActiveSupport::Concern

  def pn_ps(method)
    MutationCount::Routine
      .new(segment: self, method: method)
      .pn_ps
  end

  def dn_ds(method)
    MutationCount::Routine
      .new(segment: self, method: method)
      .dn_ds
  end

  def norm(method)
    MutationCount::Routine
      .new(segment: self, method: method)
      .norm
  end

  module ClassMethods

    BATCH = 900

    def alpha_for(segments, method)
      alpha_processor(segments, method)
    end

    def alpha_processor(segments, method)

      ids = segments.map(&:id)

      pll_map(ids, method)
      result = pll_reduce

      p = result[:p]
      d = result[:d]
      n = result[:n]

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
        snps: segments.map{|s| s.snps.count}.reduce(:+),
        divs: segments.map{|s| s.divs.count}.reduce(:+)
      }

    rescue
      return {
        pnn: '-',
        pn: '-',
        psn: '-',
        ps: '-',
        dnn: '-',
        dn: '-',
        dsn: '-',
        ds: '-',
        ns: '-',
        nn: '-',
        alpha: '-',
        snps: '-',
        divs: '-'
      }
    end

    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end

    def pll_map(ids, method)
      r = Redis.new
      ['p','d','n'].map{|k| r.del(k)}
      pll_pn_ps(ids, 'p', method)
      pll_dn_ds(ids, 'd', method)
      pll_norm( ids, 'n', method)
    end

    def pll_reduce
      r = Redis.new

      while Resque.size(:mut_count) != 0 || Resque.info[:working] != 0 do
        sleep 10
      end

      {
        :p => r.hvals('p').map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+),
        :d => r.hvals('d').map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+),
        :n => r.hvals('n').map{|v| SynCount.from_h(JSON.parse(v))}.reduce(:+)
      }
    end

    def pll_pn_ps(ids, hash_name, method)
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(PnPsWorker, slice, hash_name, method)
      end
    end

    def pll_dn_ds(ids, hash_name, method)
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(DnDsWorker, slice, hash_name, method)
      end
    end

    def pll_norm(ids, hash_name, method)
      ids.each_slice(BATCH) do |slice|
        Resque.enqueue(NormWorker, slice, hash_name, method)
      end
    end

  end

end
