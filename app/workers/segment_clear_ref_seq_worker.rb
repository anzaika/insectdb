class SegmentClearRefSeqWorker
  @queue = :all
  def self.perform(ids)
    ids.each {|id| Segment.find(id).update_attribute('_ref_seq', nil)}
  end
end
