class Mrna < ActiveRecord::Base
  include Constants
  serialize :_ref_seq

  has_and_belongs_to_many :segments

  scope :correct, -> {where(:quality_good => true)}

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

  def self.truncate_ref_seq
    Parallel.each(Mrna.all, :in_processes => 8) do |m|
      m.update_attributes(_ref_seq: nil, quality_good: nil, quality_reason: nil)
    end
    true
  end

  # Public: Set ref_seq for every mRNA in the database
  def self.set_ref_seq
    Parallel.each(Mrna.all, :in_processes => 8) do |m|
      m.ref_seq
    end
    true
  end

  # Public: Return cDNA of this mRNA.
  def ref_seq
    _ref_seq || set_ref_seq
    if _ref_seq
      return _ref_seq
    else
      set_ref_seq
      good_quality ? _ref_seq : nil
    end
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

  def positive?
    strand == '+'
  end

  private

  def set_ref_seq
    seq = cut_till_start_codon(assemble_ref_seq)
    seq = cut_till_stop_codon(seq)
    errors = check(seq)
    if errors.empty?
      update_attributes(_ref_seq: seq, good_quality: true)
    else
      update_attributes(good_quality: false, bad_quality_reason: errors.join('; '))
    end
  end

  def check(seq)
    errors = []
    errors << 'shorter than 6' unless seq.length > 5
    errors << 'seq%3 != 0'     unless seq.sseq.length%3 == 0
    errors
  end

  def assemble_ref_seq
    seq =
      segments
        .coding
        .map(&:ref_seq)
        .reduce(:+)

    positive? ? seq : seq.complement
  end

  def cut_till_start_codon(seq)
    while seq.length > 5 and seq.sseq[0,3] != 'ATG' do
      seq.shift
    end
    seq
  end

  def cut_till_stop_codon(seq)
    while seq.length > 5 and !Codon.stop_codon?(seq.sseq[-3,3]) do
      seq.pop
    end
    seq
  end

end
