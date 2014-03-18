require 'spec_helper'

describe MutationCount::Leushkin do
  let(:codon) {build(:codon, start: 4, seq: 'ACG')}
  describe '#process' do

    context 'for codon ACG at positions 4,5,6' do

      context 'and mutation CT at 5' do
        it 'returns {syn: 0.0, nonsyn: 1.0}' do
          mutation = build(:mutation, pos: 5, alleles: ['C','T'])
          count = SynCount.new(n: 1.0)
          MutationCount::Leushkin
            .new(codon: codon, mutations: [mutation])
            .run
            .should == count
        end
      end

      context 'and mutation AG at 6' do
        it 'returns {syn: 1.0, nonsyn: 0.0}' do
          mutation = build(:mutation, pos: 6, alleles: ['A','G'])
          count = SynCount.new(s: 1.0)
          MutationCount::Leushkin
            .new(codon: codon, mutations: [mutation])
            .run
            .should == count
        end
      end

      context 'and mutation AT at 18' do
        it 'returns {syn: 0.0, nonsyn: 0.0}'
      end

      context 'and mutations AT at 4 and GT at 10' do
        it 'returns {syn: 0.0, nonsyn: 0.0}'
      end

    end

  end
end
