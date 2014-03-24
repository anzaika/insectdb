class Seq < ActiveRecord::Base
  include Constants
  serialize :poly

  def self.dmel_seq(chromosome: chromosome, start: start, stop: stop)
    Sequence.new(
      self.where('chromosome = ? and position between ? and ?', chromosome, start, stop)
          .map{|r| [r[:position], self.sanitize([:dmel])]}
    )
  end

  def self.sanitize(nuc)
    nuc.gsub(/[^AGTCN]/, 'N')
  end

  def poly_san
    self.poly.map{|n| self.sanitize(n)}
  end

  def ref_san
    {
      dmel: self.sanitize(self.dmel),
      dsim: self.sanitize(self.dsim),
      dyak: self.sanitize(self.dyak)
    }
  end

  private


end
