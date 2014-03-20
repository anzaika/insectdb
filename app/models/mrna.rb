class Mrna < ActiveRecord::Base
  include Constants
  serialize :_ref_seq

  has_and_belongs_to_many :segments

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

  validates :strand,
            :presence => true,
            :inclusion => { :in => %W[ + - ] }


  # Public: Return cDNA of this mRNA.
  def ref_seq
    _ref_seq || set_ref_seq
  end

  def codons_for_segment(start: start, stop: stop)
    if positive?
      ref_seq.codons
             .select{|c| c.start >= start && c.stop <= stop}
    else
      ref_seq.codons
             .select{|c| c.start <= stop && c.stop >= start}
    end
  end

  private

  def set_ref_seq
    segments
      .coding
      .map(&:ref_seq)
      .reduce(:+)
      .tap{|seq| update_attribute('_ref_seq', positive? ? seq : seq.complement)}
  end

  def positive?
    strand == '+'
  end


end
