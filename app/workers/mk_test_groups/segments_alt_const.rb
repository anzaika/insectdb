class MkTestGroups::SegmentsAltConst
  include Constants
  def perform
    for_all_chr_different_ages
  end

  def for_all_chr_different_ages
    base = {sig_count: 145}
    execute_results(base)
  end

  private

  def execute_results(snp_params)
    render_head(snp_params)
    alt   = Segment.alpha_for(Segment.alt, **snp_params)
    const = Segment.alpha_for(Segment.const, **snp_params)
    render_table(alt, const)
  end

  def render_head(snp_params, chr=nil)
    string = snp_params.to_a.map{|a| a.join(": ")}.join(", ")
    string << " -- for chromosome #{chr}" if chr
    puts "### " + string
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
