class MkTestGroups::GenesAge
  include Constants

  def perform
    without_singletons
    with_singletons
  end

  def without_singletons
    base = {sig_count: 145, singletons: :exclude}
    execute_results(base.merge({age: :all}))
  end

  def with_singletons
    base = {sig_count: 145, singletons: :include}
    execute_results(base.merge({age: :all}))
  end


  private

  def execute_results(snp_params)
    render_head(snp_params)
    oldest = Segment.alpha_for(Gene.age_oldest.map{|g| g.segments.coding}.flatten, **snp_params)
    old    = Segment.alpha_for(Gene.age_old.map{|g| g.segments.coding}.flatten, **snp_params)
    new    = Segment.alpha_for(Gene.age_new.map{|g| g.segments.coding}.flatten, **snp_params)
    newest = Segment.alpha_for(Gene.age_newest.map{|g| g.segments.coding}.flatten, **snp_params)
    render_table(oldest, old, new, newest)
  end

  def render_head(snp_params, chr=nil)
    string = snp_params.to_a.map{|a| a.join(": ")}.join(", ")
    string << " -- for chromosome #{chr}" if chr
    puts "### " + string
  end

  def render_table(oldest, old, new, newest)
    oldest = oldest.merge({type: '111111111111'})
    old    = old.merge({type: '111111110000'})
    new    = new.merge({type: '111111000000'})
    newest = newest.merge({type: '111110000000'})

    puts Hirb::Helpers::AutoTable.render(
            [oldest, old, new, newest],
            fields: [:type, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end


end
