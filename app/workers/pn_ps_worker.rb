require 'json'

class PnPsWorker
  include Sidekiq::Worker

  def perform(id, hash_name, snp_params)
    r = Redis.new

    snp_params = snp_params.to_a.map do |a|
      [
        a.first.to_sym,
        a.last.class.name == 'String' ? a.last.to_sym : a.last
      ]
    end.to_h

    puts '*'*20
    puts snp_params.inspect
    puts '*'*20

    result = Segment.find(id)
                    .pn_ps(method: 'ermakova', **snp_params)
    r.hset(hash_name, id.to_s, result.to_json)
  end
end
