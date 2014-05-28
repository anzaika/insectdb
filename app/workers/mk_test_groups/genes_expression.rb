class MkTestGroups::GenesExpression
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
    data =
      [
        Segment.alpha_for(Gene.exp_all.map{|g| g.segments.coding}.flatten, **snp_params).merge({type: 'all'}),
        Segment.alpha_for(Gene.exp_up.map{|g| g.segments.coding}.flatten, **snp_params).merge({type: 'up'}),
        Segment.alpha_for(Gene.exp_down.map{|g| g.segments.coding}.flatten, **snp_params).merge({type: 'down'}),
        Segment.alpha_for(Gene.exp_same.map{|g| g.segments.coding}.flatten, **snp_params).merge({type: 'same'})
      ]
    render_table(data)
  end

  def render_head(snp_params, chr=nil)
    string = snp_params.to_a.map{|a| a.join(": ")}.join(", ")
    string << " -- for chromosome #{chr}" if chr
    puts "### " + string
  end

  def render_table(data)
    puts Hirb::Helpers::AutoTable.render(
            data,
            fields: [:type, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end

end
