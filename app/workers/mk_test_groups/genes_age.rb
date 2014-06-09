class MkTestGroups::GenesAge
  include Constants

  def perform(method)
    oldest = Segment.alpha_for(Gene.age_oldest.map{|g| g.segments.coding.uniq}.flatten, method)
    old    = Segment.alpha_for(Gene.age_old.map{|g| g.segments.coding.uniq}.flatten, method)
    new    = Segment.alpha_for(Gene.age_new.map{|g| g.segments.coding.uniq}.flatten, method)
    newest = Segment.alpha_for(Gene.age_newest.map{|g| g.segments.coding.uniq}.flatten, method)
    render_table(oldest, old, new, newest)
  end

  def render_table(oldest, old, new, newest)
    oldest = oldest.merge( {type: '111111111111'})
    old    = old.merge(    {type: '111111110000'})
    new    = new.merge(    {type: '111111000000'})
    newest = newest.merge( {type: '111110000000'})

    puts Hirb::Helpers::AutoTable.render(
            [oldest, old, new, newest],
            fields: [:type, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end

end
