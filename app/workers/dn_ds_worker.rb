require 'json'

class DnDsWorker
  # include Sidekiq::Worker
  @queue = :mut_count

  def self.perform(ids, hash_name, method)
    t = Time.now
    r = Redis.new

    result =
      ids.map{|id| Segment.find(id).dn_ds(method)}
         .reduce(:+)

    r.hset(hash_name, ids.first, result.to_json)
    puts 'dndsworker out //' + (Time.now-t).round(0).to_s + 's'
  end
end
