FactoryGirl.define do

  factory :div do

    ignore do
      alls ['A','G']
    end

    chromosome 0
    sequence(:position, 1)
    alleles { {dmel: alls.first, dsim: alls.last, dyak: alls.last} }

  end

end
