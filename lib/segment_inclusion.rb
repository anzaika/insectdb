module SegmentInclusion
  def self.parse_pattern( pattern )
    case pattern
    when '==='
      :none
    when '>>=', '<=>', '=<<'
      :one
    when '>>>', '<<<', '><<', '<>>', '<<>', '>><'
      :many
    end
  end

  def self.load
    File.open(Insectdb::Config::PATHS[:segmentInclusion])
        .readlines[1..(-1)]
        .map { |s| ss = s.split(","); [ss[1].to_i,ss[3]] }
        .group_by { |a| self.parse_pattern(a[1]) }
        .map { |a| [a[0], a[1].map { |inn_a| inn_a[0] }] }
        .to_hash
  end
end
