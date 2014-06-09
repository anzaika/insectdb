class Snp < ActiveRecord::Base
  include Constants
  include ToMutation
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
  def self.from_col(ref: reference,
                    poly: poly,
                    chr: chr,
                    pos: pos)

    poly_sig = poly.select{|n| n!='N'}
    allele_freqs = poly_sig.inject(Hash.new(0)){|mem, var| mem[var]+=1; mem}

    self.create!(
      :chromosome => chr,
      :position   => pos,
      :sig_count  => poly_sig.count,
      :alleles    => allele_freqs,
      :aaf        => self.aaf_from(allele_freqs, ref)
    )
  end

  # Public: Compute ancestral allele frequency (aaf)
  def self.aaf_from(freqs, ref)
    ref = (ref[:dsim] == ref[:dyak]) ? ref[:dsim] : 'N'

    if ref != 'N'
      dmel_count = freqs[ref].to_f
      all_count  = freqs.values.reduce(:+)

      return (dmel_count/all_count).round(3)
    else
      return nil
    end
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
    result = col.select{ |n| %W[A C G T].include?(n) }.uniq.size > 1
    col.count{|n| n == 'N'} > 50 ? nil : result
  end

end
