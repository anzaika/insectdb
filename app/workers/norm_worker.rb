require 'json'

class NormWorker
  include Sidekiq::Worker

  def perform(id, hash_name)
    r = Redis.new
    result = Segment.find(id)
                    .norm(method: 'ermakova')
    r.hset(hash_name, id.to_s, result.to_json)
  end
end
