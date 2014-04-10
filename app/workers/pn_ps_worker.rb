require 'json'

class PnPsWorker
  @queue = :mut_count

  def self.perform(ids, hash_name, snp_params)
    t = Time.now
    r = Redis.new

    snp_params = snp_params.to_a.map do |a|
      [
        a.first.to_sym,
        a.last.class.name == 'String' ? a.last.to_sym : a.last
      ]
    end.to_h

    result =
      ids.map{|id| Segment.find(id).pn_ps(method: 'ermakova', **snp_params)}
        .reduce(:+)

    r.hset(hash_name, ids.first, result.to_json)
    puts 'pnpsworker out //' + (Time.now-t).round(0).to_s + 's'
  end
end
