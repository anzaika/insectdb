class MkTest
  include Constants
  def perform
    for_all_chr_different_ages
    for_all_chr_different_ages_without_singletons
    for_each_chr_different_ages
    for_each_chr_different_ages_without_singletons
  end

  def for_all_chr_different_ages
    base = {sig_count: 145, singletons: :include}
    execute_results(base.merge({age: :all}))
    execute_results(base.merge({age: :old}))
    execute_results(base.merge({age: :new}))
  end

  def for_all_chr_different_ages_without_singletons
    base = {sig_count: 145, singletons: :exclude}
    execute_results(base.merge({age: :all}))
    execute_results(base.merge({age: :old}))
    execute_results(base.merge({age: :new}))
  end

  def for_each_chr_different_ages
    base = {sig_count: 145, singletons: :include}
    CHROMOSOMES.values.each do |chr|
      execute_results_for_chr(base.merge({age: :all}), chr)
      execute_results_for_chr(base.merge({age: :old}), chr)
      execute_results_for_chr(base.merge({age: :new}), chr)
    end
  end

  def for_each_chr_different_ages_without_singletons
    base = {sig_count: 145, singletons: :exclude}
    CHROMOSOMES.values.each do |chr|
      execute_results_for_chr(base.merge({age: :all}), chr)
      execute_results_for_chr(base.merge({age: :old}), chr)
      execute_results_for_chr(base.merge({age: :new}), chr)
    end
  end

  private

  def execute_results_for_chr(snp_params, chr)
    render_head(snp_params, chr)
    alt   = Segment.alpha_for(Segment.alt.where(chromosome: chr), **snp_params)
    const = Segment.alpha_for(Segment.const.where(chromosome: chr), **snp_params)
    render_table(alt, const)
  end

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
