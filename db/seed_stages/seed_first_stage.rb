########################################################
#
# Load data from db/seed_data/sequences into Seq table
#
########################################################

require_relative 'paths'

module SeedFirstStage
  class Seeder
    include Constants

    def initialize(chr: chr,
                   step: 10000,
                   processes: 30)
      @chr = chr
      @step = step
      @processes = processes
    end

    def run
      reference_seq_enums
      dmel_seq_enums
      map = (0..(reference_seq_enums[:dmel].length/@step)).map{ |v| v * @step }

      Parallel.each(map, :in_processes => @processes) do |ind|
        ActiveRecord::Base.connection.reconnect!

        dmel_en = reference_seq_enums[:dmel][ind, @step]
        dsim_en = reference_seq_enums[:dsim][ind, @step]
        dyak_en = reference_seq_enums[:dyak][ind, @step]
        snp_en  = dmel_seq_enums.map{ |e| e[ind, @step] }

        @step.times do |i|
          Seq.create(
            chromosome: CHROMOSOMES[@chr],
            position:   ind+i+1,
            dmel:       dmel_en.next,
            dsim:       dsim_en.next,
            dyak:       dyak_en.next,
            poly:       snp_en.map(&:next)
          )
        end
        dmel_en = nil
        dsim_en = nil
        dyak_en = nil
        snp_en = nil
      end
    end

    def reference_seq_enums
      @ref ||=
        reference_files
          .map{|f| SeqEnum.new(f)}
          .zip([:dmel,:dsim,:dyak])
          .map(&:reverse)
          .to_h
    end

    def dmel_seq_enums
      @dmel ||= dmel_files.map{|f| SeqEnum.new(f)}
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

  end

  class OldSeeder
    include Constants

    def start
      reference_seq_enums
      dmel_seq_enums
      step = 100000
      map = (0..(reference_seq_enums[:dmel].length/step)).map{ |v| v * step }

      Parallel.each(map, :in_processes => 14) do |ind|
        ActiveRecord::Base.connection.reconnect!

        dmel_en = reference_seq_enums[:dmel][ind, step]
        dsim_en = reference_seq_enums[:dsim][ind, step]
        dyak_en = reference_seq_enums[:dyak][ind, step]
        snp_en  = dmel_seq_enums.map{ |e| e[ind, step] }

        step.times do |i|
          processor(
            {
              :dmel => dmel_en.next,
              :dsim => dsim_en.next,
              :dyak => dyak_en.next
            },
            snp_en.map(&:next),
            ind+i+1
          )
        end
        GC.start
      end
    end

    # Public: The function makes a decision on whether the position
    #         is divergent or is an SNP. And also creates a record in
    #         reference table for this position.
    #
    # ref - Hash with dmel, dsim and dyak nucleotides.
    # dmel_col - Array with 163 dmel nucleotides.
    # chr - String with chromosome name.
    # pos - Integer with position on chromosome.
    #
    # Returns nothing.
    def processor( ref, dmel_col, pos )
      check = [
                Snp.column_is_polymorphic?(dmel_col),
                Div.position_is_divergent?(ref)
              ]

      case check
      when [true, true], [false, false] then nil
      when [true, false] then Snp.from_col(ref, dmel_col, @chr, pos)
      when [false, true] then Div.from_hash(ref, @chr, pos)
      end

      Reference.from_hash(ref, @chr, pos)
    end

    # Private: Iterate on chromosomes
    def each_chr(&block)
      CHROMOSOMES.keys.each{|chr| block.call(chr)}
    end

    def reference_seq_enums
      @ref ||=
        reference_files
          .map{|f| SeqEnum.new(f)}
          .zip([:dmel,:dsim,:dyak])
          .map(&:reverse)
          .to_h
    end

    def dmel_seq_enums
      @dmel ||= dmel_files.map{|f| SeqEnum.new(f)}
    end

    def reference_files
      [
        "drosophila_melanogaster/dm3_#{@chr}.fa.gz",
        "drosophila_simulans/droSim1_#{@chr}.fa.gz",
        "drosophila_yakuba/droYak2_#{@chr}.fa.gz"
      ].map{ |f| File.join(SEEDS[:seqs], f) }
    end

    def dmel_files
      Dir[
        File.join(SEEDS[:seqs], "drosophila_melanogaster/*_#{@chr}.fa.gz")
      ]
    end

  end
end
