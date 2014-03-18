require 'bio'

class SeqEnum
  attr_reader :length

  def initialize(input, is_path = true)
    @seq = (is_path ? fagz_to_seq(input) : input)
    # sanitize
    @length = @seq.length
    @pntr = -1
  end

  def next
    @pntr < (@length-1) ? @seq[@pntr+=1] : 'N'
  end

  def rewind
    @pntr = -1
  end

  def [](pos, step)
    SeqEnum.new(@seq[pos,step], false)
  end

  # def [](pos, step)
  #   if pos+step < @length
  #     SeqEnum.new(@seq[pos,step], false)
  #   else
  #     SeqEnum.new(@seq[pos,step] + ('N'*((pos+step)-@length)), false)
  #   end
  # end

  private

  def sanitize
    @seq.gsub!(/[^ACGTN]/,'N')
  end

  def fagz_to_seq( fagz_file_path )
    Bio::FastaFormat
      .open(Zlib::GzipReader.open(fagz_file_path))
      .entries
      .first
      .seq
      .to_s
  end

end
