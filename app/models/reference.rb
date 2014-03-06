class Reference < ActiveRecord::Base
  include Constants
  self.table_name = 'reference'

  validates :chromosome,
            :presence => true,
            :numericality => { :only_integer => true },
            :inclusion => { :in => [0, 1, 2, 3, 4] }

  validates :position,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :dmel,
            :presence => true,
            :inclusion => { :in => %W[ A C G T N ]}

  validates :dsim,
            :presence => true,
            :inclusion => { :in => %W[ A C G T N ]}

  validates :dyak,
            :presence => true,
            :inclusion => { :in => %W[ A C G T N ]}

  # Public: Create a new record from a hash with nucleotides.
  #
  # hash - The Hash with three keys :dmel, :dsim, :dyak.
  #        Each pointing to one nucleotide.
  # chr  - The String with chromosome name.
  # pos  - The Integer with position.
  #
  # Examples:
  #
  #   Inscectdb::Reference.from_hash(
  #     { :dmel => 'A',
  #       :dsim => 'A',
  #       :dyak => 'C' },
  #     '2L',
  #     69234
  #   )
  #
  # Returns Insectdb::Reference object
  def self.from_hash( hash, chr, pos )
    self.create!(
      :chromosome => Insectdb::CHROMOSOMES[chr],
      :position => pos,
      :dmel => hash[:dmel],
      :dsim => hash[:dsim],
      :dyak => hash[:dyak]
    )
  end

  # Public: Return a reference sequence.
  #
  # The reference sequence has consesus at each position in all three
  # species, i.e. D.melanogaster, D.simulans and D.yakuba.
  #
  # chr - The String or The Integer with chromosome id.
  # start - The Integer with 5' end of segment.
  # stop - The Integer with 3' end of segment.
  #
  # Examples:
  #
  #   Insectdb::Reference.ref_seq('2R', 5238, 5245)
  #                      .class == Insectdb::Sequence
  #
  # Returns Insectdb::Sequence object.
  def self.ref_seq( chr, start, stop, strand=nil )

    chromosome = (chr.class == String) ? CHROMOSOMES[chr] : chr

    seq = self.where("chromosome = ? and position between ? and ?",
                      chromosome, start, stop)
              .map do |r|
                col = [r[:dmel], r[:dsim], r[:dyak]]
                [
                  r[:position],
                  col.uniq.size > 1 ? 'N' : col[0]
                ]
              end

    Sequence.new(seq)

  end

  def self.na_eq?(nuc1, nuc2)
    (%W[A C G T].include?(nuc1)) &&
    (%W[A C G T].include?(nuc2)) &&
    (nuc1 == nuc2)
  end

end
