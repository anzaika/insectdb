require 'spec_helper'

describe MutationCount::Routine do
describe '.pn_ps' do

  context 'with Leushkin method' do

    context 'for segment with sequence ATGGCC starting at 3' do
      context 'with snps TC at 4 and CG at 7' do
        it 'returns {syn: 0.0, nonsyn: 2.0}' do
          seq = build(:sequence, start: 3, seq: 'ATGGCC')
          seg = build(:segment, seq: seq)

          snp1 = build(:snp, position: 4, alls: ['T','C'] )
          snp2 = build(:snp, position: 7, alls: ['G','C'] )
          snps = [snp1, snp2]
          seg.stub(:snps).and_return(snps)

          mrna = build(:mrna, seq: seq)
          seg.stub(:mrnas).and_return([mrna])

          count = SynCount.new(n: 2.0)

          MutationCount::Routine
            .new(segment: seg)
            .pn_ps
            .should == count
        end
      end
    end

  end
end
describe '.dn_ds'

  context 'with Ermakova method' do

    context 'for segment with sequence ATGCGTCCG starting at 3' do
      context 'with divs AT at 3, GA at 5, CA at 6, TC at 8' do
        it 'returns syn: 0.5, nonsyn: 1.5' do
          seq  = build(:sequence, start: 3, seq: 'ATGCGTCCG')
          seg  = build(:segment, seq: seq)
          divs = []
          divs << build(:div, position: 3, alls: ['A','T'] )
          divs << build(:div, position: 5, alls: ['G','A'] )
          count = SynCount.new(s: 0.5, n: 1.5)
          seg.stub(:divs).and_return(divs)

          mrna = build(:mrna, seq: seq)
          seg.stub(:mrnas).and_return([mrna])

          MutationCount::Routine
            .new(segment: seg, method: 'ermakova')
            .dn_ds
            .should == count
        end
      end
    end

    context 'for segment with sequence ATGCGTCCG starting at 3' do
      context 'with divs AT at 3, GA at 5, CA at 6, TC at 8' do
        it 'returns syn: 1.5, nonsyn: 2.5' do
          seq  = build(:sequence, start: 3, seq: 'ATGCGTCCG')
          seg  = build(:segment, seq: seq)
          divs = []
          divs << build(:div, position: 3, alls: ['A','T'] )
          divs << build(:div, position: 5, alls: ['G','A'] )
          divs << build(:div, position: 6, alls: ['C','A'] )
          divs << build(:div, position: 8, alls: ['T','C'] )
          count = SynCount.new(s: 1.5, n: 2.5)
          seg.stub(:divs).and_return(divs)

          mrna = build(:mrna, seq: seq)
          seg.stub(:mrnas).and_return([mrna])

          MutationCount::Routine
            .new(segment: seg, method: 'ermakova')
            .dn_ds
            .should == count
        end
      end
    end

  end

end
