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
