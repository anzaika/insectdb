module PnPsDnDs

  def self.compute_pnps_for_segment_scope( scope: 'alt' )
    self.pll_compute(scope: scope)
        .compact
        .reduce{ |one, two| one.merge(two){ |k,v1,v2| v1+v2 } }

  end

  def self.pll_compute( scope: scope )
    Insectdb.mapp(Insectdb::Segment.send(scope.to_s)) do |s|
      MutationCount::Routine.new(segment: s).pn_ps
    end
  end

end
