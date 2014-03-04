class Div < ActiveRecord::Base
  include Constants

  serialize :alleles

  validates :chromosome,
            :presence => true,
            :numericality => { :only_integer => true },
            :inclusion => { :in => [0, 1, 2, 3, 4] }

  validates :position,
            :presence => true,
            :numericality => { :only_integer => true }

  # Public: Create a new record from coordinates on chromosome.
  #
  # ref - The Hash with nucleotides from three organisms.
  # chr - The String with chromosome name.
  # pos - The Integer with position on chromosome.
  #
  # Examples:
  #
  #   Insectdb::Div.from_hash( {:dmel => 'A', :dsim => 'G', :dyak => 'T'}
  #                            '2R',
  #                            765986 )
  #
  # Returns The Insectdb::Div object.
  def self.from_hash( ref, chr, pos )

    self.create!(
      :chromosome => CHROMOSOMES[chr],
      :position   => pos,
      :alleles    => ref
    )

  end

  # Public: The position is considered divergent if it posesses equal
  #         nucleotides at D.simulans and D.yakuba, but a different one at
  #         D.melanogaster.
  #
  # hash - The Hash with nucleotides,
  #        e.g. {:dmel => 'A', :dsim => 'A', :dyak => 'G'}
  #
  # Examples:
  #
  #   Insectdb::Div.position_is_divergent?({ :dmel => 'A',
  #                                          :dsim => 'G',
  #                                          :dyak => 'G',}) # => true
  #
  #   Insectdb::Div.position_is_divergent?({ :dmel => 'A',
  #                                          :dsim => 'N',
  #                                          :dyak => 'N',}) # => false
  #
  #   Insectdb::Div.position_is_divergent?({ :dmel => 'N',
  #                                          :dsim => 'A',
  #                                          :dyak => 'A',}) # => false
  #
  #   Insectdb::Div.position_is_divergent?({ :dmel => 'N',
  #                                          :dsim => 'N',
  #                                          :dyak => 'N',}) # => false
  #
  #   Insectdb::Div.position_is_divergent?({ :dmel => 'A',
  #                                          :dsim => 'G',
  #                                          :dyak => 'C',}) # => false
  #
  # Returns The Boolean.
  def self.position_is_divergent?( hash )

    (hash[:dsim] == hash[:dyak]) &&
    (hash[:dmel] != hash[:dsim]) &&
    !hash.values.include?('N')

  end

  # Public: Analyses the synonimity of the mutation.
  #
  # Returns two values:
  # * synonimity of mutation - The Boolean or nil.
  # * synonimity coefficient - The Float or nil.
  def syn?

    return [nil, nil] unless codon = Segment.codon_at(chromosome, position)
    return [nil, nil] unless codon.valid?

    other_divs =
      Div.where("chromosome = ? and position in (?)",
                 chromosome,
                 codon.pos_codon.select{ |p| p != position })
    return [nil, nil] unless other_divs.empty?

    [codon.pos_syn?(position), nil]

  end

  def codon
    Segment.codon_at(chromosome, position).codon
  end

  def to_mutation
    Mutation.new(
      pos:     self.position,
      alleles: self.alleles.values.uniq
    )
  end
end
