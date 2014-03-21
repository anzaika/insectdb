require 'spec_helper'

describe Div do
describe '.to_mutation' do
  context 'given the div with alleles AGG' do
    let(:div) {build(:div, alls: ['A','G'])}
    it 'returns a mutation object with alleles AG' do
      div.to_mutation.alleles.should == ['A','G']
    end
    context 'when passed the parameter concatenate=true' do
      it 'return a mutation object with alleles TC' do
        div.to_mutation(true).alleles.should == ['T','C']
      end
    end
  end
end
end
