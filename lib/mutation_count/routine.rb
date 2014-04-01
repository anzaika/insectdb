module MutationCount
class Routine

  def initialize(segment: segment, method: 'leushkin')
    @segment = segment
    @codons  = segment.codons
    @method  = method
  end

  def pn_ps(params)
    return SynCount.new if @codons.empty? || snps(params).empty?
    build_mutcount(snps)
  end

  def dn_ds
    return SynCount.new if @codons.empty? || divs.empty?
    build_mutcount(divs)
  end

  def norm
    return SynCount.new if @codons.empty?
    @segment.codons.map(&:fractioned_syn_pos_count).reduce(:+)
  end

  private

  def build_mutcount(all_muts)
    count_for_all_codons(all_muts).reduce(:+)
  end

  def count_for_all_codons(all_muts)
    @codons.map do |codon|
      codon_muts = muts_for_codon(codon, all_muts)
      count_for_codon(codon, codon_muts)
    end
  end

  def muts_for_codon(codon, all_muts)
    poss = codon.pos_codon
    all_muts.select{|m| poss.include?(m.pos)}
  end

  def count_for_codon(codon, muts)
    self.send("#{@method}_count", codon, muts)
  end

  def ermakova_count(codon, muts)
    MutationCount::Ermakova
    .new(codon: codon, mutations: muts)
    .run
  end

  def leushkin_count(codon, muts)
    MutationCount::Leushkin
    .new(codon: codon, mutations: muts)
    .run
  end

  def snps(params={})
    @snps ||= @segment.snps(params).map{|m| m.to_mutation(negative_strand?)}
  end

  def divs
    @divs ||= @segment.divs.map{|m| m.to_mutation(negative_strand?)}
  end

  def negative_strand?
    !@segment.mrnas.first.positive?
  end

end
end
