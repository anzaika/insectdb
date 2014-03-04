class Segment < ActiveRecord::Base

  serialize :_ref_seq

  self.inheritance_column = 'inheritance_type'
  has_and_belongs_to_many :mrnas

  scope :alt,    -> { where( :type => 'coding(alt)'   )}
  scope :const,  -> { where( :type => 'coding(const)' )}
  scope :int,    -> { where( :type => 'intron'        )}
  scope :coding, -> { where( "type != 'intron'"       )}


  validates :chromosome,
            :presence => true,
            :numericality => { :only_integer => true },
            :inclusion => { :in => [0, 1, 2, 3, 4] }

  validates :start,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :stop,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :length,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :type,
            :presence => true

  # Public: A wrapper around Segment::create! to make it create a record
  #         with custom id.
  #
  # params - The Hash data for new Segment record:
  #          :id         - The Integer segment_id in insectdb4core.
  #          :chromosome - The String chromosome name, e.g. '2R'.
  #          :start      - The Integer position of the first nucleotide of
  #                        segment on the chromosome.
  #          :stop       - The Integer position of the last nucleotide of
  #                        segment on the chromosome.
  #          :type       - The String segment type as it comes from
  #                        insectdb4core.
  #          :_ref_seq   - The Insectdb::Sequnce reference sequence can be
  #                        appended, mainly for testing
  #                        purposes.
  #
  # Returns The Segment.
  def self.___create!( params )
    Insectdb::Segment.create! do |r|
      r.id         = params[:id].to_i
      r.chromosome = Insectdb::CHROMOSOMES[params[:chromosome]]
      r.start      = params[:start].to_i
      r.stop       = params[:stop].to_i
      r.type       = params[:type]
      r.length     = params[:stop].to_i - params[:start].to_i + 1
      r._ref_seq   = params[:_ref_seq] if params[:_ref_seq]
    end
  end

  def self.simple_create( id: id,
                          chr: chr,
                          start: start,
                          type: type,
                          seq: seq )

    stop = seq.length + start - 1
    ref_seq = (start..stop).zip(seq.split(''))

    self.___create!({
      :id => id,
      :chromosome => chr,
      :start => start,
      :stop => stop,
      :type => type,
      :length => ref_seq.length,
      :_ref_seq => Sequence.new(ref_seq)
    })

  end

  # Public: Remove all noncoding segments.
  #
  # Returns Integer number of records removed.
  def self.clean

    count_bfr = Insectdb::Segment.count
    puts "Rows at beginning: #{count_bfr}"

    printf "Removing non-coding segments..."
    query = Segment.where("type not in ('coding(alt)', 'coding(const)')")
    count1 = Insectdb.peach(query){ |s| s.delete }.length
    puts " #{count1} rows"

    printf "Removing segments with no mrnas..."
    query = Segment.select{ |s| s.mrnas.empty? }
    count2 = Insectdb.peach(query){ |s| s.delete }.length
    puts " #{count2} rows"

    count_aftr = Insectdb::Segment.count
    sum = count1 + count2
    percent = ((sum.to_f/count_bfr)*100).round(1)

    puts "Done, removed #{sum} rows, which is #{percent}%"
    puts "Rows now: #{count_aftr}"

  end

  # Public: Return the codon at specified location.
  #
  # Returns Codon or nil.
  def self.codon_at( chromosome, position )
    seg = Segment.where("chromosome = ? and start <= ? and stop >= ?",
                         chromosome, position, position).first
    return nil if seg.nil?

    return nil if (mrna = seg.mrnas.first).nil?

    mrna.codon_at(position)
  end

  # Public: Return all SNPs for this segment.
  #
  # Returns ActiveRecord::Relation.
  def snps(sig_count=150)

    Snp.where("chromosome = ? and position between ? and ?",
               chromosome, start, stop)
       .order("position ASC")

  end

  # Public: Return all divs for this segment.
  #
  # Returns ActiveRecord::Relation.
  def divs
    Div.where("chromosome = ? and position between ? and ?",
               chromosome, start, stop)
       .order("position ASC")
  end

  def codons
    self.ref_seq
        .codons
        .select{ |c| c.start >= self.start && c.stop <= self.stop }
  end

  # Public: Return the strand of mRNA, as part of which this segment gets
  # translated. It is assumed that strand is the same for all
  # mRNAs of this segment, so the strand value is derived
  # from any one of them.
  #
  # Returns String with + or -.
  def strand
    (mrna = self.mrnas.first) ? mrna.strand : '+'
  end

  # Public: Return the reference (i.e. of the dm3) sequence for this segment.
  #
  # Returns Insectdb::Sequence object.
  def ref_seq

    if _ref_seq
      _ref_seq
    else
      seq = Reference.ref_seq(chromosome, start, stop, strand)
      update_attributes(:_ref_seq => seq)
      seq
    end

  end

  # Public: return the GC content at the third positions of codons
  #         of this segment.
  #
  # Returns Float.
  def gc
    s = codons.map { |c| c.nuc_codon[2] }.join
    ((s.count('G')+s.count('C')).to_f/codons.count).round(4)
  end


end
