class Mutation

  attr_reader :pos, :alleles

  # params
  #  - pos: Integer
  #  - allels: Array with nucleotide letters
  def initialize(pos: pos, alleles: alleles)
    @pos = pos
    @alleles = alleles
  end

end
