class MutatingCodon

  def self.mut_cod_match?(codon: codon, mutation: mutation)
    mutation.alleles.include?(codon.nuc_at(mutation.pos))
  end

  def initialize(codon)
    @cod = codon
  end

  def mutate_with(mutation)
    @mut = mutation
    check_mutation ? build_mutated_codon : nil
  end

  private

  def build_mutated_codon
    pos_codon = @cod.pos_codon.clone
    nuc_codon = @cod.nuc_codon.clone
    nuc_codon[inner_mut_pos] = mutated_allele
    Codon.new(pos_codon.zip(nuc_codon))
  end

  def inner_mut_pos
    @cod.glob_to_int(@mut.pos)
  end

  def mutated_allele
    @mut.alleles.find{|n| n != original_allele}
  end

  def original_allele
    @original_allele ||= @cod.nuc_at(@mut.pos)
  end

  def check_mutation
    mut_pos_correct?
  end

  # Private: One of mutation alleles should be present in codon at
  # correct position
  def mut_alleles_correct?
    @mut.alleles.include?(original_allele)
  end

  # Private: Mutation location should be within this codon.
  def mut_pos_correct?
    @cod.pos_codon.include?(@mut.pos)
  end


end
