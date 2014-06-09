module Analytics::DivSnpCounts
  include Constants

  SEGS_IN_BIN = 400

  def self.run
    self.submit_jobs

    while Resque.size(:all) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end

    puts '### Seed stage 3 complete'
  end

  def self.submit_jobs
    self.bins.each do |bin|
      Resque.enqueue(DivSnpCountsWorker, bin)
    end
  end

  def self.bins
    Segment.coding
           .pluck(:id)
           .each_slice(SEGS_IN_BIN)
           .to_a
  end

  class Worker
    include Constants

    def initialize(bin)
      @bin = bin
      @r = Redis.new
    end

    def id_to_positions_and_chr(id)
      seg = Segment.find(id)
      [seg.chromosome, seg.positions]
    end

    def run
      @bin.each{|id| batch_processor(*id_to_positions_and_chr(id))}
    end

    def batch_processor(chr, poss)
      poss.each{|p| position_processor(p, chr)}
    end

    #############################
    ###### Important logic ######
    #############################
    # SNP and divergence cannot be detected simultaneously at the same
    # position.

    def position_processor(pos, chr)
      seq = seq_at(pos, chr)
      ref = seq.ref_san
      dyak = ref[:dyak]
      dsim = ref[:dsim]
      dmel = ref[:dmel]

      if dsim == dmel && dyak != dsim
        @r.incr 'dyak'
      elsif dyak == dmel && dsim != dmel
        @r.incr 'dsim'
      elsif dyak == dsim && dmel != dsim
        @r.incr 'dmel'
      end
    end

    def seq_at(pos, chr)
      Seq.where(chromosome: chr, position: pos).first
    end
  end

end
