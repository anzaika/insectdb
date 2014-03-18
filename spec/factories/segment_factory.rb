FactoryGirl.define do

  factory :segment do

    ignore do
      seq {build(:sequence)}
    end

    sequence(:id, 1)
    _ref_seq { seq }
    chromosome 0
    start { seq.start }
    stop  { seq.stop  }
    sequence(:type){|i| ['coding(const)', 'coding(alt)'][i%2]}

  end

end
