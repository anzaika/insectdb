require 'spec_helper'

describe MutationCount::Leushkin do
  describe '#mut_position' do
    it 'returns mutation position in inner codon coordinates, i.e. 0,1,2' do
      # MutationCount::Leushkin.mut_position
      codon = Codon.new( codon: [ [4, 'A'], [5, 'C'], [6, 'G'] ] )
      mutation = double('Snp')
      mutation.stub(:pos).and_return(5)

      MutationCount::Leushkin
        .mut_position( codon: codon, mutation: mutation)
        .should == 1
    end
  end

  describe '#get_result' do

    context 'for codon ACG and mutation at second position ' do
      it 'returns {syn: 0.0, nonsyn: 1.0}' do
        codon = Codon.new( codon: [ [4, 'A'], [5, 'C'], [6, 'G'] ] )
        mutation = double('Snp')
        mutation.stub(:pos).and_return(5)

        MutationCount::Leushkin
          .get_result( codon: codon, mutation: mutation)
          .should == { syn: 0.0, nonsyn: 1.0}
      end
    end

    context 'for codon GCC and mutation at third position' do
      it 'returns {syn: 1.0, nonsyn: 0.0}' do
        codon = Codon.new( codon: [ [4, 'G'], [5, 'C'], [6, 'C'] ] )
        mutation = double('Snp')
        mutation.stub(:pos).and_return(6)

        MutationCount::Leushkin
          .get_result( codon: codon, mutation: mutation)
          .should == { syn: 1.0, nonsyn: 0.0}
      end
    end

  end
end
