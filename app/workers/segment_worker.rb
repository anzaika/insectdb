class SegmentWorker
  @queue = :all
  def self.perform(ids)
    ids.each {|id| Segment.find(id).ref_seq}
  end
end
