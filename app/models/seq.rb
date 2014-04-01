class Seq < ActiveRecord::Base
  include Constants
  serialize :poly

  def self.sanitize(nuc)
    nuc.gsub(/[^AGTCN]/, 'N')
  end

  def sanitize(nuc)
    nuc.gsub(/[^AGTCN]/, 'N')
  end

  def self.dmel_seq(chromosome: chromosome, start: start, stop: stop)
    Sequence.new(
      self.where('chromosome = ? and position between ? and ?', chromosome, start, stop)
          .map{|r| [r[:position], self.sanitize(r[:dmel])]}
    )
  end

  def poly_san
    self.poly.map{|n| self.sanitize(n)}
  end

  def ref_san
    {
      dmel: sanitize(self.dmel),
      dsim: sanitize(self.dsim),
      dyak: sanitize(self.dyak)
    }
  end

end
