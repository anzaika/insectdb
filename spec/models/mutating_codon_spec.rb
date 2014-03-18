require 'spec_helper'

describe MutatingCodon do
describe ".mutate_with" do
  context "given the codon ATG, on positions 1,2,3" do
    let(:codon) {build(:codon, seq: 'ATG')}

    context "with mutation TC at position 2" do
      it "returns codon ACG" do
        codon_after_seq = build(:codon, seq: 'ACG').seq
        mutation = build(:mutation, pos: 2, alleles: ['T','C'])
        MutatingCodon
          .new(codon)
          .mutate_with(mutation)
          .seq
          .should == codon_after_seq
      end
    end

    context "with mutation GA at position 3" do
      it "returns codon ATA" do
        codon_after_seq = build(:codon, seq: 'ATA').seq
        mutation = build(:mutation, pos: 3, alleles: ['G','A'])
        MutatingCodon
          .new(codon)
          .mutate_with(mutation)
          .seq
          .should == codon_after_seq
      end
    end

    context "with mutation TA at position 3" do
      it "returns nil" do
        mutation = build(:mutation, pos: 3, alleles: ['T','A'])
        MutatingCodon
          .new(codon)
          .mutate_with(mutation)
          .should be_nil
      end
    end

    context "with mutation TA at position 5" do
      it "returns nil" do
        mutation = build(:mutation, pos: 5, alleles: ['T','A'])
        MutatingCodon
          .new(codon)
          .mutate_with(mutation)
          .should be_nil
      end
    end

  end
end
end
