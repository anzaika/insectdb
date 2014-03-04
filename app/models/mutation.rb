class Mutation

  attr_reader :pos, :alleles

  # params
  #  - pos: Integer
  #  - allels: Array with nucleotide letters
  def initialize( pos: pos, alleles: alleles)
    @pos = pos

    case alleles.class
    when Array then @alleles = alleles
    when String then @alleles = alleles.split('')
    end

  end

end
