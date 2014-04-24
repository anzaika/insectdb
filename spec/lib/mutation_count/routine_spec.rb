require 'spec_helper'

describe MutationCount::Routine do
describe '.pn_ps' do
  context 'with Leushkin method' do

    context 'for segment with sequence ATGGCC starting at 3' do
      context 'with snps TC at 4 and CG at 7' do
        it 'returns {syn: 0.0, nonsyn: 2.0}' do
          pending
          seq = build(:sequence, start: 3, seq: 'ATGGCC')
          seg = create(:segment, seq: seq)

          create(:snp, position: 4, alls: ['T','C'] )
          create(:snp, position: 7, alls: ['G','C'] )

          count = SynCount.new(n: 2.0)

          MutationCount::Routine
            .new(segment: seg)
            .pn_ps
            .should == count
        end
      end
    end

    context 'for segment with sequence GGCCAT starting at 4' do
      context 'with snps AG at 5 and CG at 8' do
        it 'returns {syn: 0.0, nonsyn: 2.0}' do
          pending
          seq = build(:sequence, start: 4, seq: 'GGCCAT')
          seg = create(:segment, seq: seq)

          create(:snp, position: 5, alls: ['A','G'] )
          create(:snp, position: 8, alls: ['G','C'] )

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

    context 'for segment with sequence ATGCGTCCG starting at 4' do
      context 'with divs AT at 4, GA at 6' do
        it 'returns syn: 0.5, nonsyn: 1.5' do
          seq = build(:sequence, start: 4, seq: 'ATGCGTCCG')
          seg = create(:segment, seq: seq)

          create(:div, position: 4, alls: ['A','T'] )
          create(:div, position: 6, alls: ['G','A'] )

          count = SynCount.new(s: 0.5, n: 1.5)

          MutationCount::Routine
            .new(segment: seg, method: 'ermakova')
            .dn_ds
            .should == count
        end
      end
      context 'with divs AT at 4, GA at 6, CA at 7, TC at 9' do
        it 'returns syn: 1.5, nonsyn: 2.5' do
          seq = build(:sequence, start: 4, seq: 'ATGCGTCCG')
          seg = create(:segment, seq: seq)

          create(:div, position: 4, alls: ['A','T'] )
          create(:div, position: 6, alls: ['G','A'] )
          create(:div, position: 7, alls: ['C','A'] )
          create(:div, position: 9, alls: ['T','C'] )

          count = SynCount.new(s: 1.5, n: 2.5)

          MutationCount::Routine
            .new(segment: seg, method: 'ermakova')
            .dn_ds
            .should == count
        end
      end
    end

  end

end
