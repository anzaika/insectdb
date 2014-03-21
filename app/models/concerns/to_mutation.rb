module ToMutation
  extend ActiveSupport::Concern

  def to_mutation(concatenate=false)
    case self.class.name
    when 'Div'
      alls = [alleles[:dmel], alleles[:dsim]]
    when 'Snp'
      alls = alleles.keys
    end

    Mutation.new(
      pos:     position,
      alleles: (concatenate ? comp_alleles(alls) : alls)
    )
  end

  def comp_alleles(alleles)
    alleles.map{|a| Bio::Sequence::NA.new(a).complement.upcase}
  end

end
