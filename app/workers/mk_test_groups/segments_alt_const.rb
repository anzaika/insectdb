class MkTestGroups::SegmentsAltConst

  include Constants
  def perform(method)
    alt   = Segment.alpha_for(Segment.alt, method)
    const = Segment.alpha_for(Segment.const, method)
    render_table(alt, const)
  end

  def render_table(alt, const)
    alt = alt.merge({type: :alternative})
    const = const.merge({type: :constant})
    puts Hirb::Helpers::AutoTable.render(
            [alt, const],
            fields: [:type, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end

end
