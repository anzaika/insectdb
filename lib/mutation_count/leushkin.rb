module MutationCount
module Leushkin

  ZERO = {:syn => 0.0, :nonsyn => 0.0}

  def self.process( codon: codon, mutations: mutations )

    if mutations.size != 1
      return ZERO
    else
      self.get_result(codon: codon, mutation: mutations.first)
    end

  end

  def self.mut_position( codon: codon, mutation: mutation )
    codon.pos_codon
         .index(mutation.pos)
  end

  def self.get_result( codon: codon, mutation: mutation )

    unless sitemap = Codon::SITE_SYNONYMITY[codon.nuc_codon.join]
      return ZERO
    end

    case sitemap[self.mut_position(codon: codon, mutation: mutation)]
    when 'u'
      ZERO
    when 's'
      {:syn => 1.0, :nonsyn => 0.0}
    when 'n'
      {:syn => 0.0, :nonsyn => 1.0}
    end

  end

end
end
