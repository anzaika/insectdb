FactoryGirl.define do

  factory :codon do

    ignore do
      start 1
      seq 'ACG'
    end

    initialize_with do
      Codon.simple_create(start: start, seq: seq)
    end

  end

end
