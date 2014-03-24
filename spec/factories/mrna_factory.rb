FactoryGirl.define do
  factory :mrna do

    sequence(:id, 1)
    chromosome 0
    strand '+'
    start 3
    stop 8
    good_quality true

    factory :mrna_with_seq do
      ignore do
        seq {build(:sequence)}
      end
      start { seq.start }
      stop { seq.stop }
      _ref_seq {seq}
    end

    factory :mrna_with_one_segment do
      ignore do
        seq {build(:sequence)}
      end

      start { seq.start }
      stop { seq.stop }
      after(:create) do |m, evaluator|
        s = create(:segment, seq: evaluator.seq);
        create(:mrnas_segments, segment_id: s.id, mrna_id: m.id )
      end
    end

    factory :mrna_with_two_segments do
      ignore do
        seq1 {build(:sequence, start: 10)}
        seq2 {build(:sequence, start: 30)}
      end

      start {seq1.start}
      stop  {seq2.stop}
      after(:create) do |m, evaluator|
        s1 = create(:segment, seq: evaluator.seq1);
        s2 = create(:segment, seq: evaluator.seq2);
        create(:mrnas_segments, segment_id: s1.id, mrna_id: m.id )
        create(:mrnas_segments, segment_id: s2.id, mrna_id: m.id )
      end
    end

  end

end
