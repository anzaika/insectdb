########################################################
#
# Populate Div and Snp tables with data from Seq table
#
########################################################

module SeedThirdStage
  include Constants

  SEGS_IN_BIN = 200

  def self.run
    self.submit_jobs

    while Resque.size(:seed) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end

    puts '### Seed stage 3 complete'
  end

  def self.submit_jobs
    self.bins.each do |bin|
      Resque.enqueue(SeedThirdStageWorker, bin)
    end
  end

  def self.bins
    Segment.coding
           .pluck(:id)
           .each_slice(SEGS_IN_BIN)
           .to_a
  end

  class Seeder
    include Constants

    def initialize(bin)
      @bin = bin
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
      poly = seq.poly_san

      case check(ref, poly)
      when [true, false], [true, true] then Snp.from_col(ref: ref, poly: poly, chr: chr, pos: pos)
      when [false, true] then Div.from_hash(ref: ref, chr: chr, pos: pos)
      else nil
      end
    end

    def simpler__position_processor(pos)
      seq = seq_at(pos)
      ref = seq.ref_san
      poly = seq.poly_san

      if Snp.column_is_polymorphic?(poly)
        Snp.from_col(ref: ref, poly: poly, chr: @chr, pos: pos)
      end

      if Div.simpler__position_is_divergent?(ref)
        Div.from_hash(ref: ref, chr: @chr, pos: pos)
      end
    end

    def check(ref, poly)
      [
        Snp.column_is_polymorphic?(poly),
        Div.position_is_divergent?(ref)
      ]
    end

    #############################
    #############################
    #############################

    def seq_at(pos, chr)
      Seq.where(chromosome: chr, position: pos-1).first
    end

  end
end
