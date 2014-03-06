require 'spec_helper'

describe MutationCount::Routine do

  describe '#pn_ps' do
    it 'returns a hash' do
      MutationCount::Routine.new(
        segment: Fabricate(:segment)
      ).pn_ps.class.should == Hash
    end
    context 'with Leushkin method' do
      context 'for segment with sequence ATG and mutation at second base' do
        it 'returns {syn: 0.0, nonsyn: 1.0}' do
          seg = Fabricate(:segment) do
            _ref_seq Sequence.new([[1,'A'], [2,'T'], [3,'G']])
          end

          snp = Fabricate(:snp) do
            position 2
          end

          seg.stub(:snps).and_return([snp])

          MutationCount::Routine
            .new(segment: seg)
            .pn_ps
            .should == {syn: 0.0, nonsyn: 1.0}
        end
      end
      context 'for segment with sequence GCC and mutation at third base' do
        it 'returns {syn: 1.0, nonsyn: 0.0}' do
          seg = Fabricate(:segment) do
            _ref_seq Sequence.new([[1,'G'], [2,'C'], [3,'C']])
          end

          snp = Fabricate(:snp) do
            position 3
          end

          seg.stub(:snps).and_return([snp])

          MutationCount::Routine
            .new(segment: seg)
            .pn_ps
            .should == {syn: 1.0, nonsyn: 0.0}
        end
      end
    end
  end

end
