class DivSnpCountsWorker
  @queue = :all
  def self.perform(bin)
    Analytics::DivSnpCounts::Worker.new(bin).run
  end
end
