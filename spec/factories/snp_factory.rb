FactoryGirl.define do

  factory :snp do

    ignore do
      alls ['A','G']
      freqs [150,12]
    end

    chromosome 0
    sequence(:position, 1)
    sig_count 162
    alleles { alls.split('').zip(freqs).to_h }

  end

end
