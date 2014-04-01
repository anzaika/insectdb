require 'json'

class DnDsWorker
  include Sidekiq::Worker

  def perform(id, hash_name)
    r = Redis.new
    result = Segment.find(id)
                    .dn_ds(method: 'ermakova')
    r.hset(hash_name, id.to_s, result.to_json)
  end
end
