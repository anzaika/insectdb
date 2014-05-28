class MkTestGroups::SegmentsAltConstAsymptotic

  include Constants
  def perform
    alt
    const
  end

  private

  def alt
    puts "### Alternative"
    alt = Segment.asymptotic_alpha_for(Segment.alt.first(900))
    render_table(alt)
  end

  def const
    puts "### Constant"
    const = Segment.asymptotic_alpha_for(Segment.const.first(900))
    render_table(const)
  end

  def render_table(data)
    puts Hirb::Helpers::AutoTable.render(
            data,
            fields: [:aaf, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end

end
