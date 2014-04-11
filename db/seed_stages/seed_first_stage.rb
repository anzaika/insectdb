########################################################
#
# Load data from db/seed_data/sequences into Seq table
#
########################################################

require_relative 'paths'

module SeedFirstStage
  include Constants

  # Production
  STEP_DEFAULT = 4000000
  CHR_LENGTH_DEFAULT = 28000000

  # Test
  # STEP_DEFAULT = 50
  # CHR_LENGTH_DEFAULT = 100

  def self.run(step: STEP_DEFAULT)
    CHROMOSOMES.keys.each do |chr|
      self.submit_jobs(chr, step)
    end

    while Resque.size(:seed) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end

    puts '### Seed stage 1 complete'
  end

  def self.submit_jobs(chr, step)
    self.block_count(chr, step).times do |i|
      Resque.enqueue(SeedFirstStageWorker, chr, i, step)
    end
  end

  def self.block_count(chr, step)
    (CHR_LENGTH_DEFAULT/step.to_f).ceil
  end

  class Seeder
    include Constants

    def initialize(chr, index, step)
      @chr = chr
      @start = (index * step + 1)
      @step = step
    end

    def reference_seq_enums
      reference_files
        .map{|f| SeqEnum.new(f)}
        .zip([:dmel,:dsim,:dyak])
        .map(&:reverse)
        .to_h
    end

    def dmel_seq_enums
      dmel_files.map{|f| SeqEnum.new(f)}
    end

    def reference_files
      [
        "drosophila_melanogaster/dm3_#{@chr}.fa.gz",
        "drosophila_simulans/droSim1_#{@chr}.fa.gz",
        "drosophila_yakuba/droYak2_#{@chr}.fa.gz"
      ].map{ |f| File.join(Insectdb::SEEDS[:seqs], f) }
    end

    def dmel_files
      Dir[
        File.join(Insectdb::SEEDS[:seqs], "drosophila_melanogaster/*_#{@chr}.fa.gz")
      ]
    end

    def enums
      ref  = reference_seq_enums
      poly = dmel_seq_enums

      dmel_en = ref[:dmel][@start, @step]
      dsim_en = ref[:dsim][@start, @step]
      dyak_en = ref[:dyak][@start, @step]
      poly_en = poly.map{|e| e[@start, @step]}

      ref = nil
      poly = nil
      GC.start

      {
        dmel: dmel_en,
        dsim: dsim_en,
        dyak: dyak_en,
        poly: poly_en
      }
    end

    def run
      e = enums
      @step.times do |i|
        Seq.create(
          chromosome: CHROMOSOMES[@chr],
          position:   @start+i,
          dmel:       e[:dmel].next,
          dsim:       e[:dsim].next,
          dyak:       e[:dyak].next,
          poly:       e[:poly].map(&:next)
        )
      end
    end

  end
end
