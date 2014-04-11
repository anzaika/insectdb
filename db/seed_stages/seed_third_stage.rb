########################################################
#
# Populate Div and Snp tables with data from Seq table
#
########################################################

module SeedThirdStage
  include Constants

  # Production
  STEP_DEFAULT = 500000

  # Test
  # STEP_DEFAULT = 20

  def self.run(step: STEP_DEFAULT)
    CHROMOSOMES.keys.each do |chr|
      self.submit_jobs(chr, step)
    end

    while Resque.size(:seed) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end

    puts '### Seed stage 3 complete'
  end

  def self.submit_jobs(chr, step)
    self.block_count(chr, step).times do |i|
      Resque.enqueue(SeedThirdStageWorker, chr, i, step)
    end
  end

  def self.block_count(chr, step)
    (self.base_count(chr)/step.to_f).ceil
  end

  def self.base_count(chr)
    Seq.where(chromosome: CHROMOSOMES[chr]).count
  end

  class Seeder
    include Constants

    def initialize(chr, index, step)
      @chr = chr
      @poss = positions_at(index, step)
    end

    def positions_at(index, step)
      start = (index * step + 1)
      stop  = start + step
      (start...stop).to_a
    end

    def run
      batch_processor(@poss)
    end

    def batch_processor(poss)
      poss.each{|p| position_processor(p)}
    end

    #############################
    ###### Important logic ######
    #############################
    # SNP and divergence cannot be detected simultaneously at the same
    # position.

    def position_processor(pos)
      seq = seq_at(pos)
      ref = seq.ref_san
      poly = seq.poly_san

      case check(ref, poly)
      when [true, true], [false, false] then nil
      when [true, false] then Snp.from_col(ref: ref, poly: poly, chr: @chr, pos: pos)
      when [false, true] then Div.from_hash(ref: ref, chr: @chr, pos: pos)
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

    def seq_at(pos)
      Seq.where(chromosome: CHROMOSOMES[@chr], position: pos).first
    end

  end
end
