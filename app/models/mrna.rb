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

  def set_ref_seq
    segments.map(&:ref_seq)
            .reduce(:+)
            .tap{|seq| update_attribute('_ref_seq', seq)}
  end

end
