module SeedThirdStage

  def self.for_all
  end

  class Seeder
    include Constants
    def initialize(
      chromosome: chromosome,
      processes: 30,
      step: 10000)

      @chr = chromosome
      @step = step
      @processes = processes
      @pll_index = (0...(block_count(step))).to_a
    end

    def run
      Parallel.each(@pll_index, :in_processes => @processes) do |i|
        batch_processor(positions_at(i))
      end
    end

    def batch_processor(positions)
      positions.each{|p| position_processor(p)}
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

      Reference.from_hash(ref, @chr, pos)
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

    def block_count(step)
      (base_count/step.to_f).ceil
    end

    def base_count
      Seq.where(chromosome: CHROMOSOMES[@chr]).count
    end

    def positions_at(index)
      start = (index * @step + 1)
      stop  = start + @step
      (start...stop).to_a
    end

  end
end
