module MutationCount
class Routine

  def initialize( segment: segment, method: 'leushkin')

    @snps    = segment.snps.map(&:to_mutation)
    @divs    = segment.divs.map(&:to_mutation)
    @codons  = segment.codons
    @method  = method

  end

  def pn_ps
    return {:syn => 0.0, :nonsyn => 0.0} if @codons.empty? || @snps.empty?
    mut_map(muts: @snps).map{ |s| mutcount(struct: s) }
                        .reduce{ |one, two| one.merge(two){ |k,v1,v2| v1+v2 } }
  end

  def dn_ds
    return {:syn => 0.0, :nonsyn => 0.0} if @codons.empty? || @divs.empty?
    mut_map(muts: @divs).map{ |s| mutcount(struct: s) }
                        .reduce{ |one, two| one.merge(two){ |k,v1,v2| v1+v2 } }
  end

  ### Private ###

  def mutcount( struct: struct )
    MutationCount.const_get(@method.capitalize)
                           .process(codon:     struct.codon,
                                    mutations: struct.mutations)
  end

  # Creates an array with OpesStructs. Struct is comprised of a codon
  # and mutations associated with it. Only Structs with more than zero mutations
  # find its way into the resulting array.
  def mut_map( muts: muts)
    aggregate_muts(muts: muts).compact
  end

  def aggregate_muts( muts: muts )
    # mut = nil
    # @codons.map{ |c| muts_for_codon_fast(codon: c, muts_enum: muts.each, mut: mut) }
    @codons.map{ |c| muts_for_codon_slow(codon: c, muts: muts) }
  end

  def muts_for_codon_slow( codon: codon, muts: muts)
    mut_set = muts.select{ |m| codon.pos_codon.include?(m.pos) }
    mut_set.empty? ? nil : OpenStruct.new(codon: codon, mutations: mut_set)
  end

  def muts_for_codon_fast( codon: codon, muts_enum: muts_enum, mut: mut)

    mut_set = []

    while codon.stop >= (mut ||= muts_enum.next).position do
      mut_set << mut
      mut = muts_enum.next
    end

    mut_set.empty? ? nil : OpenStruct.new(codon: c, mutations: mut_set)

  end


end
end
