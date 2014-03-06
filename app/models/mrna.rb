class Mrna < ActiveRecord::Base
  include Constants

  serialize :_ref_seq

  # has_and_belongs_to_many :genes
  has_and_belongs_to_many :segments

  composed_of :test

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

  # Public: Create a new record from passed params.
  #
  # In Activerecord the only method that can implicitly set primary key
  # values is the #create!. So this method just proxies all the params
  # with minor changes and type conversions to the aforementioned method.
  def self.___create!( params )

    Insectdb::Mrna.create! do |r|
      r.id         = params[:id].to_i
      r.chromosome = CHROMOSOMES[params[:chromosome]]
      r.strand     = params[:strand]
      r.start      = params[:start].to_i
      r.stop       = params[:stop].to_i
      r._ref_seq   = params[:_ref_seq] if params[:_ref_seq]
    end

  end

  # Public: Remove segmentless mRNAs.
  def self.clean

    Insectdb.peach(Mrna.all, 20) { |m| m.delete if m.segments.empty? }

    nil

  end

  # Public: Check cDNA start codon in all mRNAs. It should be ATG.
  def self.validity_check

    Insectdb.mapp(Mrna.all, 10) { |m| m.validity_check }
            .count{ |r| r == false }

  end

  # Public: Check cDNA start and stop codons.
  def validity_check

    if strand == '+'

      codon = ref_seq[0..2].map(&:last).join
      return true if codon.include?('N')
      codon == 'ATG'

    elsif strand == '-'

      codon = ref_seq[-3..-1].map(&:last).join
      return true if codon.include?('N')
      codon == 'CAT'

    end

  end

  # Public: Make all mRNAs generate their reference sequences by calling
  #         their Mrna#ref_seq method. This function does this in 5
  #         parallel threads.
  #
  # Returns nothing.
  def self.set_ref_seq

    Insectdb.peach(CHROMOSOMES.values, 5) do |chr|

      Mrna.where(:chromosome => chr).each(&:ref_seq)

    end

    nil

  end

  # Public: Return codon that includes this position.
  #
  # Returns the Codon object.
  def codon_at( position )

    ref_seq.codon_at(position)

  rescue => e

    warn "-"*30
    warn self.inspect
    warn e.inspect
    warn "-"*30
    raise

  end

  # Public: Return cDNA of this mRNA.
  def ref_seq

    _ref_seq || set_ref_seq

  rescue => e

    warn "-"*30
    warn self.inspect
    warn e.inspect
    warn "-"*30
    return Sequence.new([])

  end

  # Private: Update _ref_seq attribute.
  def set_ref_seq

      seq = segments.map(&:ref_seq).reduce(:+)
      update_attributes(:_ref_seq => seq)

      seq

  end

end
