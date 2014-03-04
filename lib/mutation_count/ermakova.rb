module MutationCount
module Ermakova

  ZERO = {:syn => 0.0, :nonsyn => 0.0}

  def self.process( codon: codon, mutations: mutations )

    # Norm is the coefficent equal to the total number of transitions
    # in all paths.
    norm = 0

    # Eliminating the mutations that have alleles not present in codon at
    # desired location i.e. ATG and [2,[CG]]
    valid_muts = mutations.select{ |m| codon.mutate(m) }

    return {true => 0.0, false => 0.0} if valid_muts.size == 0

    valid_muts
      .permutation
      .to_a
      .map{ |muts| self.build_path(codon, muts) }
      .tap{ |paths| norm = paths.count * valid_muts.count }
      .map{ |path| self.process_path(path) }
      .flatten
      .reduce(Hash.new(0)){ |h,v| h[v] += 1; h }
      .tap{ |hash| hash[true] /= norm.to_f; hash[false] /= norm.to_f }

  end

  # Private: Build a single from a sequence of mutations applied onto codon.
  #
  # codon     - Codon
  # mutations - Array with simplified Snp or Div objects
  #
  # Returns the Array or nil.
  def self.build_path( codon, mutations )

      mutations.reduce([codon]) do |p, mut|
        p[-1] ? p.push(p[-1].mutate(mut)) : nil
      end

  end

  # Private: count syn and nonsyn mutations in a path.
  #
  # path - an Array with Codon objects
  #
  # Returns an Array.
  def self.process_path( path )

    result = []

    path.reduce do |f, s|
      result.push(f.translate == s.translate) unless (f.nil? || s.nil?)
      s
    end

    result

  end

end
end
