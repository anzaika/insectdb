require 'json'

class NormWorker
  @queue = :mut_count

  def self.perform(ids, hash_name)
    t = Time.now
    r = Redis.new

    result =
      ids.map{|id| Segment.find(id).norm(method: 'ermakova')}
        .reduce(:+)

    r.hset(hash_name, ids.first, result.to_json)
    puts 'normworker out //' + (Time.now-t).round(0).to_s + 's'
  end
end
