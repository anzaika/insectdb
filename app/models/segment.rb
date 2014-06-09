class Segment < ActiveRecord::Base
  include Constants
  include MutCountable
  serialize :_ref_seq

  self.inheritance_column = 'inheritance_type'
  has_and_belongs_to_many :mrnas

  scope :alt,    -> { where( :type => 'coding(alt)'   )}
  scope :const,  -> { where( :type => 'coding(const)' )}
  scope :int,    -> { where( :type => 'intron'        )}
  scope :coding, -> { where( "type in ('coding(alt)', 'coding(const)')")}
  scope :noncoding, -> { where( "type not in ('coding(alt)', 'coding(const)')")}

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

  validates :type,
            :presence => true

  before_create :set_length

  def self.clear_ref_seq
    Segment.all.pluck(:id).each_slice(100) do |slice|
      Resque.enqueue(SegmentClearRefSeqWorker, slice)
    end
    while Resque.size(:all) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end
  end

  # Public: Set ref_seq for every segment in the database
  def self.set_ref_seq
    Segment.coding.pluck(:id).each_slice(300) do |slice|
      Resque.enqueue(SegmentWorker, slice)
    end
    while Resque.size(:all) != 0 || Resque.info[:working] != 0 do
      sleep 10
    end
  end

  def positions
    (start..stop).to_a
  end

  # Public: Return all SNPs for this segment.
  #
  # Returns ActiveRecord::Relation.
  def snps
    Snp.where("chromosome = ? and sig_count >= ? and aaf <= ? and position between ? and ?",
              chromosome, 145, 0.85, start, stop)
       .select{ |s| !s.alleles.values.include?(1) }
  end

  def snps_all
    Snp.where("chromosome = ? and sig_count >= 145 and position between ? and ?",
              chromosome, start, stop)
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
    ms = mrnas.select(&:good_quality)
    unless ms.empty?
      ms.first.codons_for_segment(start: start, stop: stop)
    else
      []
    end
  end

  def strand
    (mrna = mrnas.first) ? mrna.strand : nil
  end

  # Public: Return the reference (i.e. of the dm3) sequence for this segment.
  #
  # Returns Insectdb::Sequence object.
  def ref_seq
    _ref_seq || set_ref_seq
  end

  # Public: return the GC content at the third positions of codons
  #         of this segment.
  #
  # Returns Float.
  def gc
    s = codons.map { |c| c.nuc_codon[2] }.join
    ((s.count('G')+s.count('C')).to_f/codons.count).round(4)
  end

  private

  def set_length
    self.length = stop - start + 1
  end

  def set_ref_seq
    Seq.ref_seq(chromosome: chromosome, start: start, stop: stop)
       .tap{|seq| update_attribute('_ref_seq', seq)}
  end

end
