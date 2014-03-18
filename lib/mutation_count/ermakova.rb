module MutationCount
class Ermakova

  def initialize(codon: codon, mutations: mutations)
    @cod = codon
    @muts = mutations
    @count = SynCount.new
  end

  def run
    build_result if passes_check?
    @count
  end

  private

  def passes_check?
    got_muts?
  end

  def got_muts?
    !@muts.empty?
  end

  def build_result
    counts = interpret_all_codon_paths
    @count.s = (counts[true]/@muts.count.to_f).round(1)
    @count.n = (counts[false]/@muts.count.to_f).round(1)
  end

  def interpret_all_codon_paths
    build_codon_paths
      .map {|p| interpret_codon_path(p)}
      .flatten
      .reduce(Hash.new(0)){|h,v| h[v]+=1; h}
  end

  def build_codon_paths
    build_mut_paths.map {|mp| codon_path_from(mp)}
  end

  def build_mut_paths
    @muts.permutation.to_a
  end

  def interpret_codon_path(path)
    result = []
    (path.length-1).times do |i|
      result << Codon.codons_syn?(path[i, 2])
    end
    result
  end

  def codon_path_from(mut_path)
    result = [@cod]
    mut_path.each do |m|
      result << MutatingCodon.new(result[-1]).mutate_with(m)
    end
    result
  end



end
end
