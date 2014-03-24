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

        it "returns a Sequence ATGTAA" do
          mrna.ref_seq.sseq.should == 'ATGTAA'
        end

        it "returns a Sequence with positions 8 through 13" do
          mrna.ref_seq.pos_seq.should == (8..13).to_a
        end

        it "sets quality good field to true" do
          mrna.good_quality.should be_true
        end

      end

      context "with two segments 1,6 ATGCCC and 9,11 TAA" do

        let(:seq1){build(:sequence, start: 1, seq: 'ATGCCC')}
        let(:seq2){build(:sequence, start: 9, seq: 'TAA')}
        let(:mrna){create(:mrna_with_two_segments, seq1: seq1, seq2: seq2)}

        it "returns a Sequence ATGCCCTAA" do
          mrna.ref_seq.sseq.should == 'ATGCCCTAA'
        end

        it "returns a Sequence with positions [1..6, 9..11]" do
          mrna.ref_seq.pos_seq.should == (1..6).to_a+(9..11).to_a
        end

        it "sets quality good field to true" do
          mrna.good_quality.should be_true
        end

      end

      context "with two segments 1,7 CATGCCC and 9,12 TAAC" do

        let(:seq1){build(:sequence, start: 1, seq: 'CATGCCC')}
        let(:seq2){build(:sequence, start: 9, seq: 'TAAC')}
        let(:mrna){create(:mrna_with_two_segments, seq1: seq1, seq2: seq2)}

        it "returns a Sequence ATGCCCTAA" do
          mrna.ref_seq.sseq.should == 'ATGCCCTAA'
        end

        it "returns a Sequence with positions [2..7, 9..11]" do
          mrna.ref_seq.pos_seq.should == (2..7).to_a+(9..11).to_a
        end

        it "sets quality good field to true" do
          mrna.good_quality.should be_true
        end
      end

      context "with two segments 1,6 CTGCCC and 9,11 TAA" do

        let(:seq1){build(:sequence, start: 1, seq: 'CTGCCC')}
        let(:seq2){build(:sequence, start: 9, seq: 'TAA')}
        let(:mrna){create(:mrna_with_two_segments, seq1: seq1, seq2: seq2)}

        it "returns nil" do
          mrna.ref_seq.should be_nil
        end

        it "sets quality_good field to false" do
          mrna.ref_seq
          mrna.good_quality.should be_false
        end

        it "sets quality_reason field to empty seq after cuts" do
          mrna.ref_seq
          mrna.bad_quality_reason.should == 'shorter than 6; seq%3 != 0'
        end

      end
    end

    context "given an mRNA on negative strand" do

      context "with one segment on 1,6 and sequence TTACAT" do

        let(:seq) {build(:sequence, start: 1, seq: 'TTACAT')}
        let(:mrna) {create(:mrna_with_one_segment, seq: seq, strand: '-')}

        it "returns a Sequence object" do
          mrna.ref_seq.class.name.should == 'Sequence'
        end

        it "returns a Sequence ATGTAA" do
          mrna.ref_seq.sseq.should == 'ATGTAA'
        end

        it "returns a Sequence with position 6 through 1" do
          mrna.ref_seq.pos_seq.should == (1..6).to_a.reverse
        end

      end

      context "with two segments 1,6 TTAGGG and 9,11 CAT" do

        let(:seq1){build(:sequence, start: 1, seq: 'TTAGGG')}
        let(:seq2){build(:sequence, start: 9, seq: 'CAT')}
        let(:mrna){create(:mrna_with_two_segments, strand: '-', seq1: seq1, seq2: seq2)}

        it "returns a Sequence ATGCCCTAA" do
          mrna.ref_seq.sseq.should == 'ATGCCCTAA'
        end

        it "returns a Sequence with positions [11..9, 6..1]" do
          mrna.ref_seq.pos_seq.should == ((1..6).to_a+(9..11).to_a).reverse
        end

        it "sets quality good field to true" do
          mrna.ref_seq
          mrna.good_quality.should be_true
        end

      end

      context "with two segments 1,7 CTTAGGG and 9,12 CATT" do

        let(:seq1){build(:sequence, start: 1, seq: 'CTTAGGG')}
        let(:seq2){build(:sequence, start: 9, seq: 'CATT')}
        let(:mrna){create(:mrna_with_two_segments, strand: '-', seq1: seq1, seq2: seq2)}

        it "returns a Sequence ATGCCCTAA" do
          mrna.ref_seq.sseq.should == 'ATGCCCTAA'
        end

        it "returns a Sequence with positions [11..9, 6..2]" do
          mrna.ref_seq.pos_seq.should == ((2..7).to_a+(9..11).to_a).reverse
        end

        it "sets quality good field to true" do
          mrna.ref_seq
          mrna.good_quality.should be_true
        end

      end

      context "with two segments 1,6 CTGCCC and 9,11 TAA" do

        let(:seq1){build(:sequence, start: 1, seq: 'CTGCCC')}
        let(:seq2){build(:sequence, start: 9, seq: 'TAA')}
        let(:mrna){create(:mrna_with_two_segments, strand: '-', seq1: seq1, seq2: seq2)}

        it "returns nil" do
          mrna.ref_seq.should be_nil
        end

        it "sets quality_good field to false" do
          mrna.ref_seq
          mrna.good_quality.should be_false
        end

        it "sets quality_reason field to 'shorter than 6; seq%3 != 0'" do
          mrna.ref_seq
          mrna.bad_quality_reason.should == 'shorter than 6; seq%3 != 0'
        end

      end
    end
  end
end
