class MutatingCodon

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
    mut_alleles_correct? && mut_pos_correct?
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

  # Public: Apply mutation onto this codon.
  #
  # Examples:
  #
  #   Codon.new([[1,'A'],[2,'C'],[3,'C']])
  #                  .mutate(mutation)
  #
  # mutation -  The Mutation object
  #
  # Returns a Codon.
  # def mutate
  #   base_ind = @codon.index{ |a| a[0] == mutation.pos }
  #   new_nuc = mutate_nucleotide(current_nuc, mutation.alleles)

  #   # if mutation has no common nucleotides with this codon

  #   new_codon = @codon.clone
  #   new_codon[ind] = [mutation.pos, new_nuc]

  #   Codon.new(codon: new_codon)
  # end

  # # Private: Return a mutated nucleotide value for the
  # # existing nucleotide and mutation pattern passed.
  # def mutate_nucleotide(nuc, nuc_arr)
  #   nuc_arr.find{|n| n != nuc}
  # end

end
