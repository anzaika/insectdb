class Segment < ActiveRecord::Base
  include Constants
  include MutCountable
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

  validates :type,
            :presence => true

  before_save :set_length

  # Public: Return all SNPs for this segment.
  #
  # Returns ActiveRecord::Relation.
  def snps(sig_count=150)
    Snp.where("chromosome = ? and sig_count >= ? and position between ? and ?",
               chromosome, sig_count, start, stop)
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
    if mrnas.count > 0
      mrnas
        .first
        .ref_seq
        .codons
        .select{ |c| c.start >= self.start && c.stop <= self.stop }
    else
      nil
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

  def set_ref_seq
    Seq.dmel_seq(chromosome: chromosome, start: start, stop: stop)
       .tap{|seq| update_attribute('_ref_seq', seq)}
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
    self.length = stop - start
  end

end
