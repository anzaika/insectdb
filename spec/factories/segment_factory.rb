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

    after(:create) do |s, evaluator|
      seq_start = build(:sequence, start: 1,   seq: 'ATG')
      seq_stop  = build(:sequence, start: 100, seq: 'TAA')
      seq = seq_start+evaluator.seq+seq_stop
      m = create(:mrna_with_seq, seq: seq)
      create(:mrnas_segments, segment_id: s.id, mrna_id: m.id )
    end

  end
end
