module Seed

  SEPARATOR = ';'

  # Public: Initiates seeding of reference, div and snp databases.
  #
  # Returns nothing.
  def self.seqs
    puts "Seeding Reference, Div and Snp"
    Insectdb::CHROMOSOMES.keys.each do |chr|
      printf "--for chromosome #{chr} "
      time = Time.now
      self._seqs(Insectdb::Config::PATHS[:seqs], chr)
      puts "took #{time} sec"
    end
    nil
  end

  def self.segments
    self._exec_and_format(:segments) do |l|
      Insectdb::Segment.create! do |r|
        r.id         = l[0].to_i
        r.chromosome = Insectdb::CHROMOSOMES[l[1]]
        r.start      = l[2].to_i
        r.stop       = l[3].to_i
        r.type       = l[4]
        r.length     = l[3].to_i - l[2].to_i
      end
    end
  end

  def self.mrnas
    self._exec_and_format(:mrnas) do |l|
      Insectdb::Mrna.create! do |r|
        r.id         = l[0].to_i
        r.chromosome = Insectdb::CHROMOSOMES[l[1]]
        r.strand     = l[2]
        r.start      = l[3].to_i
        r.stop       = l[4].to_i
      end
    end
  end

  def self.genes
    self._exec_and_format(:genes) do |l|
      Insectdb::Gene.create! do |r|
        r.id         = l[0].to_i
        r.flybase_id = l[1]
      end
    end
  end

  def self.mrnas_segments
    self._exec_and_format(:mrnas_segments) do |l|
      Insectdb::MrnasSegments.create!(
        :mrna_id    => l[0].to_i,
        :segment_id => l[1].to_i
      )
    end
  end

  def self.genes_mrnas
    self._exec_and_format(:genes_mrnas) do |l|
      Insectdb::GenesMrnas.create!(
        :mrna_id => l[0].to_i,
        :gene_id => l[1].to_i
      )
    end
  end

  def self.reference_enums_for( chr, path )
    [
      "drosophila_melanogaster/dm3_#{chr}.fa.gz",
      "drosophila_simulans/droSim1_#{chr}.fa.gz",
      "drosophila_yakuba/droYak2_#{chr}.fa.gz"
    ].map{ |f| SeqEnum.new(File.join(path, f)) }
      .zip([:dmel,:dsim,:dyak])
      .map(&:reverse)
      .to_hash
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
  def self.seq_processor( ref, dmel_col, chr, pos )
    check = [
              Snp.column_is_polymorphic?(dmel_col),
              Div.position_is_divergent?(ref)
            ]

    case check
    when [true, true], [false, false] then nil
    when [true, false] then Snp.from_col(ref, dmel_col, chr, pos)
    when [false, true] then Insectdb::Div.from_hash(ref, chr, pos)
    end

    Insectdb::Reference.from_hash(ref, chr, pos)

    return nil
  end

  # Private: Seed Reference, Snp and Div tables for one chromosome
  def self._seqs( path, chr )
    ref_enums = reference_enums_for(chr, path)

    snp_enums =
      Dir[File.join(path, "drosophila_melanogaster/*_#{chr}.fa.gz")]
        .map { |f| SeqEnum.new(f) }

    step = (ENV['ENV'] == 'test' ? 5 : 200000)
    map = (0..(ref_enums[:dmel].length/step)).map{ |v| v * step }

    Parallel.each(map, :in_processes => (ENV['ENV'] == 'test' ? 0 : 10)) do |ind|
      ActiveRecord::Base.connection.reconnect!

      dmel_en = ref_enums[:dmel][ind, step]
      dsim_en = ref_enums[:dsim][ind, step]
      dyak_en = ref_enums[:dyak][ind, step]
      snp_en  = snp_enums.map{ |e| e[ind, step] }

      step.times do |i|
        self.seq_processor(
          {
            :dmel => dmel_en.next,
            :dsim => dsim_en.next,
            :dyak => dyak_en.next
          },
          snp_en.map(&:next),
          chr,
          ind+i+1
        )
      end
    end
  end

  def self._exec_and_catch_errors( path, &block )
    errors = []
    File.open(File.join(path),'r') do |f|
      f.lines.each_with_index do |l, ind|
        begin
          l = l.chomp.split(SEPARATOR)
          block.call(l)
        rescue => e
          errors.push({
            :line => ind + 1,
            :content => l.join(" | "),
            :error => e
          })
        end
      end
    end
    errors
  end

  def self._exec_and_format( sym, &block )
    printf "Seeding #{sym.to_s.capitalize}... "

    start = Time.now
    errors = self._exec_and_catch_errors(Insectdb::Config::PATHS[sym], &block)
    time = (Time.now - start).round

    puts "took #{time} sec"
    puts "Errors: #{errors.size}"
    puts ''
    errors.each do |e|
      puts "When processing line #{e[:line]}:"
      puts "-> #{e[:content]}"
      puts "Reason:"
      puts "-> #{e[:error].inspect}"
      puts ""
    end
  end

  # TODO: copy-paste from Segment, needs fixing
  # Public: Set bind_mean field for all coding segments.
  #
  # The value is counted only for position that happen to be 'A' or 'T'
  #
  # Returns: True or message "Looks like finished"
  def self.seed_bind_mean( path )
    segs = Insectdb::Segment
             .coding
             .where(:chromosome => '2L')
             .order(:start)

    ends = segs.map{|s| [s.start, s.stop]}

    bind =
      File.open(path)
        .lines
        .map{|li| l=li.chomp.split(","); l[0]=l[0].to_i; l[1]=l[1].to_f; l }
        .sort_by(&:first)
        .each

    prev_el = nil
    pos_hold = []

    ends.each_with_index do |iends, ind|
      el = prev_el || bind.next
      if el.first < iends.first
        prev_el = nil
        redo
      elsif (el.first >= iends.first) && (el.first <= iends.last)
        pos_hold << el
        prev_el = nil
        redo
      else
        prev_el = el
        next if pos_hold.empty?
        pos_hold = pos_hold.select{ |b| %W[A T].include?(segs[ind].ref_seq[b.first]) }
        segs[ind].update_attributes('bind_mean' => pos_hold.map(&:last).mean)
        pos_hold = []
      end
    end

    true
  rescue StopIteration
    warn 'Looks like finished'
  end

end
