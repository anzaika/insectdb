require 'spec_helper'

describe Mrna do
  describe ".ref_seq" do

    context "given an mRNA on positive strand" do

      context "with one segment (8, ATGTAA)" do

        let(:seq) {build(:sequence, start: 8, seq: 'ATGTAA')}
        let(:mrna) {create(:mrna_with_one_segment, seq: seq)}

        it "returns a Sequence object" do
          mrna.ref_seq.class.name.should == 'Sequence'
        end

      end
    end
  end
end

