require 'spec_helper'

describe Codon do
  let(:codon) {build(:codon, start: 5, seq: 'ATG')}
  describe '.glob_to_int' do
    context 'given codon ATG on positions 5,6,7' do
      it 'returns 1 for input 6' do
        codon.glob_to_int(6)
             .should == 1
      end
    end
  end
  describe '.nuc_at' do
    context 'given codon ATG on positions 5,6,7' do
      it 'returns G for input 7' do
        codon.nuc_at(7)
             .should == 'G'
      end
    end
  end
end
