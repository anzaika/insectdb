class SeqSeed
  include Constants

  def self.for_each_chromosome
    CHROMOSOMES.keys.each{|chr| self.new(chr).start}
  end

  def initialize(chromosome)
    @chr = chromosome
  end

  def start
    reference_seq_enums
    dmel_seq_enums
    step = 100000
    map = (0..(reference_seq_enums[:dmel].length/step)).map{ |v| v * step }

    Parallel.each(map, :in_processes => 24) do |ind|
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
