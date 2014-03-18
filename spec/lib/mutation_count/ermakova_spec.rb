require 'spec_helper'

describe MutationCount::Ermakova do
describe '.run' do

  context 'for codon ATG with start at 4' do
    let(:codon) {build(:codon, start: 4, seq: 'ATG')}

    context 'and mutation AT at 5' do
      it 'returns {syn: 0.0, nonsyn: 1.0}' do
        mut1 = build(:mutation, pos: 5, alleles: ['A','T'])
        muts = [mut1]
        count = SynCount.new(n: 1.0)

        MutationCount::Ermakova
          .new(codon: codon, mutations: muts)
          .run
          .should == count
      end
    end

    context 'and mutations AT at 4 and GA at 6' do
      it 'returns {syn: 0.5, nonsyn: 1.5}' do
        mut1 = build(:mutation, pos: 4, alleles: ['A','T'])
        mut2 = build(:mutation, pos: 6, alleles: ['A','G'])
        muts = [mut1, mut2]
        count = SynCount.new(s: 0.5, n: 1.5)

        MutationCount::Ermakova
          .new(codon: codon, mutations: muts)
          .run
          .should == count
      end
    end

    context 'and mutation AT at 18' do
      it 'returns {syn: 0.0, nonsyn: 0.0}'
    end

    context 'and mutations AT at 4 and GT at 10' do
      it 'returns {syn: 0.0, nonsyn: 1.0}'
    end

  end

  context 'for codon CGT with start at 4' do
    context 'and mutations TC at 6 and CA at 4' do
      it 'returns {syn: 1.0, nonsyn: 1.0}' do
        codon = build(:codon, start: 4, seq: 'CGT')
        mut1 = build(:mutation, pos: 6, alleles: ['T','C'])
        mut2 = build(:mutation, pos: 4, alleles: ['C','A'])
        muts = [mut1, mut2]
        count = SynCount.new(s: 1.0, n: 1.0)

        MutationCount::Ermakova
          .new(codon: codon, mutations: muts)
          .run
          .should == count
      end
    end
  end

end
end
