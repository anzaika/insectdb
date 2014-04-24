class MrnaClearRefSeqWorker
  @queue = :all
  def self.perform(ids)
    ids.each {|id| Mrna.find(id).update_attributes('_ref_seq' => nil, 'good_quality' => nil, 'bad_quality_reason' => nil)}
  end
end
