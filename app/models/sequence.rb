class Sequence
  include Constants
  attr_reader :seq, :strand

  # Public
  #
  # seq_with_coords - The Array with positions and nucleotides, i.e. [[1,'A'],[2,'G']]
  #
  # Returns the Sequence object.
  def initialize( seq_with_coords )
    @seq = seq_with_coords
  end

  # Public: Return the array with nucleotides of this sequence.
  #
  # Examples:
  #
  #   Sequnce.new([[1,'A'],[2,'G']]).nuc_seq #=> ['A','G']
  #
  # Returns the Array.
  def nuc_seq
    @seq.map(&:last)
  end

  # Public: Return NA sequence as the String.
  #
  # Returns The String.
  def sseq
      @seq.map(&:last).join
  end

  # Public: Return nucleotide at position.
  #
  # pos - The Integer
  #
  # Returns The String or nil.
  def []( pos )
    @seq[pos]
  end

  # Public: Return the length of the sequence
  #
  # Returns The Integer.
  def length
    @seq.length
  end

  # Public: Concatenate with another sequence.
  #
  # oseq - The Sequence object
  def +( oseq )
    Sequence.new( (@seq + oseq.seq).sort_by{ |e| e.first } )
  end

  # Public: Split in triplets and return one that has the position.
  #
  # position - The Integer.
  #
  # Returns The Codon.
  def codon_at( position )

    ind = @seq.index{ |p| p.first == position }

    return nil unless (length >= 3) && ind && (ind < ((length/3)*3))

    # codon start position
    csp = (ind/3)*3

    range = csp..(csp+2)

    Codon.new( codon: @seq[range] )

  end

  # Public: Return the Array with Codon objects.
  def codons

    return [] if length < 3

    @seq.each_slice(3)
        .map { |c| c.size == 3 ? Codon.new(codon: c) : nil }
        .compact

  end

  # Public: Return codon usage quantities.
  #
  # Returns The Hash.
  def codon_usage
    Bio::Sequence::NA.new(sseq).codon_usage
  end

  # Public: Return String with sequnce
  #
  # Examples:
  #
  #   Sequnce.new([[1,'A'],[2,'G']],'+').raw_seq #=> 'AG'
  def raw_seq
    @seq.map(&:last).join
  end

  def to_s

    return sseq if (length < 14)

    nuc_seq[0..5].join.to_s + '...' + nuc_seq[-6..-1].join.to_s

  end

  def start
    @seq[0][0]
  end

  def stop
    @seq[-1][0]
  end

end
