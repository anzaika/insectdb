class Snp < ActiveRecord::Base
  include Constants
  serialize :alleles

  validates :chromosome,
           :presence => true,
            :numericality => { :only_integer => true },
            :inclusion => { :in => [0, 1, 2, 3, 4] }

  validates :position,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :sig_count,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :alleles,
            :presence => true

  # Public: Create a new record from an array of nucleotides.
  #
  # ref - The Hash with reference nucleotides.
  # col - The Array with nucleotides.
  # chr - The String with chromosome.
  # pos - The Integer with position of nucleotide column.
  #
  # Examples:
  #
  #   Insectdb::Snp.from_col(
  #     {:dmel => 'A', :dsim => 'G', :dyak => 'T'}
  #     ['A','A','A','A','C','C'],
  #     '2R',
  #     87765
  #   )
  #
  # Returns the Insectdb::Snp object.
  def self.from_col( ref, col, chr, pos )
    alleles = col.select{ |n| n != 'N'}
                 .inject(Hash.new(0)) { |mem, var| mem[var]+=1; mem }

    self.create!(
      :chromosome => Insectdb::CHROMOSOMES[chr],
      :position   => pos,
      :sig_count  => col.select { |n| n != 'N' }.size,
      :alleles    => alleles,
      :aaf        => ((alleles[ref[:dmel]])/
                      (alleles.values.reduce(:+)).to_f).round
    )
  end

  # Public: When parsing 163 aligned Drosophila melanogaster sequences column
  #         by column, it is necessary to check each column for being a
  #         polymorphic column.
  #         By definition the column of nucleotides is considered to be
  #         polymorphic if contains more than two types of nucleotide letters.
  #         See the examples for details.
  #
  # col - The Array with nucleotides
  #
  # Examples:
  #
  #   Insectdb::Snp.column_is_polymorphic?(%W[ A A C ]) # => true
  #   Insectdb::Snp.column_is_polymorphic?(%W[ A G C ]) # => true
  #   Insectdb::Snp.column_is_polymorphic?(%W[ A A N ]) # => false
  #   Insectdb::Snp.column_is_polymorphic?(%W[ A A A ]) # => false
  #   Insectdb::Snp.column_is_polymorphic?(%W[ N N N ]) # => false
  #   Insectdb::Snp.column_is_polymorphic?([])          # => false
  #
  # Returns The Boolean.
  def self.column_is_polymorphic?( col )
    col.select{ |n| %W[A C G T].include?(n) }.uniq.size > 1
  end

  # Public: Analyses the synonimity of the mutation.
  #
  # Returns two values:
  # * synonimity of mutation - The Boolean or nil.
  # * synonimity coefficient - The Float or nil.
  def syn?

    unless (codon = Segment.codon_at(chromosome, position)) && codon.valid?
      return [nil, nil]
    end

    other_snps =
      Snp.where("chromosome = ? and position in (?)",
                 chromosome,
                 codon.pos_codon.select{ |p| p != position })
    return [nil, nil] unless other_snps.empty?

    [codon.pos_syn?(position), nil]

  end

  def to_mutation
    Mutation.new(
      pos:     self.position,
      alleles: self.alleles.keys
    )
  end

end
