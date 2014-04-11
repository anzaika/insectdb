class MrnaWorker
  @queue = :all
  def self.perform(ids)
    ids.each {|id| Mrna.find(id).ref_seq}
  end
end
