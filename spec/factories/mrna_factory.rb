FactoryGirl.define do
  factory :mrna do

    ignore do
      seq {build(:sequence)}
    end

    sequence(:id, 1)
    _ref_seq { seq }
    chromosome 0
    strand '+'
    start { seq.start }
    stop { seq.stop }

  end

end
