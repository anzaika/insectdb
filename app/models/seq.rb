class Seq < ActiveRecord::Base
  include Constants
  serialize :poly

  def self.dmel_seq(chromosome: chromosome, start: start, stop: stop)
    Sequence.new(
      self.where('chromosome = ? and position between ? and ?', chromosome, start, stop)
          .map{|r| [r[:position], r[:dmel].gsub(/[^AGTCN]/,'N')]}
    )
  end

  def poly_san
    self.poly.map{|n| sanitize(n)}
  end

  def ref_san
    {
      dmel: sanitize(self.dmel),
      dsim: sanitize(self.dsim),
      dyak: sanitize(self.dyak)
    }
  end

  private

  def sanitize(nuc)
    nuc.gsub(/[^AGTCN]/, 'N')
  end

end
