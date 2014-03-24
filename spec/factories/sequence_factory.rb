FactoryGirl.define do

  factory :sequence do

    ignore do
      start 1
      seq 'ATGCCCTAA'
    end

    initialize_with do
      Sequence.simple_create(start: start, seq: seq)
    end

  end

end
