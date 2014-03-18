class Seq < ActiveRecord::Base
  serialize :poly

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
