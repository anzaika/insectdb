module SegmentGain
  def self.load
    File.open(Insectdb::Config::PATHS[:segmentGain])
        .readlines[1..(-1)]
        .tap { |a| warn "Read #{a.count} lines from file #{Insectdb::Config::PATHS[:segmentGain]}" }
        .map { |s| s.split(";") }
        .group_by { |s| s[1] }
        .tap { |h| warn "Clusterization by gene_id id produced #{h.size} clusters" }
        .values
        .map { |a| a.select { |s| s[0] == 'Dmel' }.flatten }
        .map { |s| [s[3], s[5].to_i-1, s[8].chomp] }
        .group_by{ |s| s.last }
        .map do |a|
          [ a[0],
            a[1].map { |s| (seg = Insectdb::Segment.coding.where(:chromosome => s[0]).where(:start => s[1]).first) ? seg.id : nil  }
                .compact ]
        end.to_hash
  end

  def self.mkd_for_each_pattern_cluster
    self.load
        .map do |a|
          ActiveRecord::Base.connection.reconnect!
          [a[0], a[1].empty? ? nil : Insectdb::Segment.mkd_for(Insectdb::Segment.where("id in (?)", a[1])) ]
        end.to_hash
  end

end
