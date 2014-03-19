class Codon
  include Constants

  attr_reader :codon

  # Hash with 'codon'<->'site synonimity map'
  # If a site mutation in codon always results in
  # amino-acid change then site is marked as 'n'.
  # If a site mutation in codon never results in
  # amino-acid change then site is marked as 's'.
  # If a site mutation in codon sometimes changes
  # the amino-acid and sometimes not then site is marked as 'u'.
  SITE_SYNONYMITY = {
    'GCC' => 'nns',
    'AGT' => 'nnu',
    'TGA' => 'uuu',
    'TGT' => 'nnu',
    'CGA' => 'uns',
    'ATC' => 'nnu',
    'AAC' => 'nnu',
    'AGC' => 'nnu',
    'TAC' => 'nnu',
    'ACA' => 'nns',
    'TCG' => 'nns',
    'CCG' => 'nns',
    'CTG' => 'uns',
    'GCA' => 'nns',
    'GTG' => 'uns',
    'AAG' => 'nnu',
    'GTT' => 'nns',
    'CAC' => 'nnu',
    'AGA' => 'unu',
    'ACC' => 'nns',
    'CCA' => 'nns',
    'TGG' => 'unu',
    'CGC' => 'nns',
    'CTC' => 'nns',
    'TTG' => 'unu',
    'TAA' => 'nuu',
    'CAG' => 'nnu',
    'ACG' => 'nns',
    'ATG' => 'unu',
    'AAA' => 'nnu',
    'GTA' => 'uns',
    'CTT' => 'nns',
    'TAG' => 'nnu',
    'GGA' => 'uns',
    'GTC' => 'nns',
    'TGC' => 'nnu',
    'TCA' => 'nus',
    'ATT' => 'nnu',
    'TAT' => 'nnu',
    'AAT' => 'nnu',
    'ACT' => 'nns',
    'CAA' => 'nnu',
    'GAC' => 'nnu',
    'GGT' => 'nns',
    'TCC' => 'nns',
    'TTT' => 'nnu',
    'AGG' => 'unu',
    'CGT' => 'nns',
    'ATA' => 'unu',
    'CAT' => 'nnu',
    'CGG' => 'uns',
    'GGG' => 'uns',
    'CCC' => 'nns',
    'GAG' => 'nnu',
    'TTA' => 'uuu',
    'CTA' => 'uns',
    'GAT' => 'nnu',
    'TCT' => 'nns',
    'TTC' => 'nnu',
    'GCG' => 'nns',
    'GGC' => 'nns',
    'GAA' => 'nnu',
    'GCT' => 'nns',
    'CCT' => 'nns'
  }

  R = 2.87230166688849

  FRACTIONED_SITE_SYNONIMITY = {
      'GCC' => 1,
      'AGT' => R/(1+R),
      'TGA' => nil,
      'TGT' => R/(0.5+R),
      'CGA' => 1.5,
      'ATC' => (0.5+R)/(1+R),
      'AAC' => R/(1+R),
      'AGC' => R/(1+R),
      'TAC' => 1,
      'ACA' => 1,
      'TCG' => 1,
      'CCG' => 1,
      'CTG' => (1+2*R)/(1+R),
      'GCA' => 1,
      'GTG' => 1,
      'AAG' => R/(1+R),
      'GTT' => 1,
      'CAC' => R/(1+R),
      'AGA' => 1/(1+2*R)+R/(1+R),
      'ACC' => 1,
      'CCA' => 1,
      'TGG' => 0,
      'CGC' => 1,
      'CTC' => 1,
      'TTG' => 2*R/(1+R),
      'TAA' => nil,
      'CAG' => R/(1+R),
      'ACG' => 1,
      'ATG' => 0,
      'AAA' => R/(1+R),
      'GTA' => 1,
      'CTT' => 1,
      'TAG' => nil,
      'GGA' => 1,
      'GTC' => 1,
      'TGC' => R/(0.5+R),
      'TCA' => 1,
      'ATT' => (0.5+R)/(1+R),
      'TAT' => 1,
      'AAT' => R/(1+R),
      'ACT' => 1,
      'CAA' => R/(1+R),
      'GAC' => R/(1+R),
      'GGT' => 1,
      'TCC' => 1,
      'TTT' => R/(1+R),
      'AGG' => (0.5+R)/(1+R),
      'CGT' => 1,
      'ATA' => 1/(1+R),
      'CAT' => R/(1+R),
      'CGG' => (1.5+R)/(1+R),
      'GGG' => 1,
      'CCC' => 1,
      'GAG' => R/(1+R),
      'TTA' => 2*R/(1+R),
      'CTA' => (1+2*R)/(1+R),
      'GAT' => R/(1+R),
      'TCT' => 1,
      'TTC' => R/(1+R),
      'GCG' => 1,
      'GGC' => 1,
      'GAA' => R/(1+R),
      'GCT' => 1,
      'CCT' => 1
    }

  # Check whether two codons code for the same aa
  #
  # @return [Boolean]
  def self.codons_syn?(codons)
    codons.first.translate == codons.last.translate
  end

  # Check codon for being a stop codon
  #
  # @param [Array] codon ['T','A','G']
  # @return [Boolean]
  def self.stop_codon?(codon)
    translate(codon) == '*' ? true : false
  end

  def self.simple_create(start: start, seq: seq)
    codon_arr = (start..(start+2)).zip(seq.split(''))
    self.new(codon_arr)
  end

  # Public
  #
  # codon - The Array of this structure: [[1,'A'],[2,'G'],[3,'C']]
  #
  # Returns The Codon object.
  def initialize(codon)
    if (codon.class != Array) ||
       (codon.size != 3)
      raise ArgumentError,
            "Codon must have three bases, but this was passed: #{codon}"
    end
    @codon = codon
  end

  def ==(other_codon)
    self.nuc_codon == other_codon.nuc_codon &&
    self.pos_codon == other_codon.pos_codon
  end

  def glob_to_int(pos)
    pos - start
  end

  def syn_map
    SITE_SYNONYMITY[nuc_codon.join]
  end

  def fractioned_syn_pos_count
    syn = FRACTIONED_SITE_SYNONIMITY[nuc_codon.join]
    syn ? SynCount.new(s: syn, n: 3-syn) : SynCount.new
  end

  def seq
    nuc_codon.join
  end

  def nuc_at(global_pos)
    nuc_codon[glob_to_int(global_pos)]
  end

  def nuc_codon
    @nuc_codon ||= @codon.map(&:last)
  end

  def pos_codon
    @pos_codon ||= @codon.map(&:first)
  end

  def start
    @codon[0][0]
  end

  def stop
    @codon[-1][0]
  end

  def base(n)
    @codon[n]
  end

  def translate
    Bio::Sequence::NA.new(nuc_codon.join).translate
  end

  def valid?
    translate
  end

  def has_pos?( pos )
    pos_codon.include?(pos)
  end

  # Public: Return coordinates of synonymous or nonsynonymous positions.
  #
  # Examples:
  #   poss('syn')
  #   # => [26, 27]
  #
  # @param [Array] codon
  # @return [Array] array of Integers
  def poss( syn )
    cod = SITE_SYNONYMITY[nuc_codon.join]
    return [] unless cod

    pos_codon
      .zip(cod.split(""))
      .select{|p| p.last == (syn=='syn' ? 's' : 'n')}
      .map(&:first)
  end

  def pos_syn?(position)
    poss('syn').include?(position)
  end

end
