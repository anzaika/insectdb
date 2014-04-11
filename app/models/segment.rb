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

  # Public: Set ref_seq for every segment in the database
  def self.set_ref_seq
    Segment.all.pluck(:id).each_slice(100) do |slice|
      Resque.enqueue(SegmentWorker, slice)
    end
  end

  # Public: Return all SNPs for this segment.
  #
  # Returns ActiveRecord::Relation.
  def snps(sig_count: 150, aaf: 0.5, age: :all, singletons: :exclude)
    if age == :all
      result =
        Snp.where("chromosome = ? and sig_count >= ? and position between ? and ?",
                  chromosome, sig_count, start, stop)
    elsif age == :old
      result =
        Snp.where("chromosome = ? and sig_count >= ? and aaf < ? and position between ? and ?",
                  chromosome, sig_count, aaf, start, stop)
    elsif age == :new
      result =
        Snp.where("chromosome = ? and sig_count >= ? and aaf >= ? and position between ? and ?",
                  chromosome, sig_count, aaf, start, stop)
    else
      raise 'Unknown age passed: ' + age.to_s
    end

    if singletons == :exclude
       result = result.select{|s| !s.alleles.values.include?(1) }
    end

    result
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
    Seq.dmel_seq(chromosome: chromosome, start: start, stop: stop)
       .tap{|seq| update_attribute('_ref_seq', seq)}
  end

end
