class MkTestGroups::GenesExpression
  include Constants

  def perform(method)
    base_data =
      [
        Gene.exp_all,
        Gene.exp_up,
        Gene.exp_down,
        Gene.exp_same
      ]

    data =
      base_data
        .map { |genes|    genes.map{|g| g.segments.coding.uniq}.flatten  }
        .map { |segments| Segment.alpha_for(segments, method)            }

    data[0] = data[0].merge({type: 'all'})
    data[1] = data[1].merge({type: 'up'})
    data[2] = data[2].merge({type: 'down'})
    data[3] = data[3].merge({type: 'same'})

    render_table(data)
  end

  def render_table(data)
    puts Hirb::Helpers::AutoTable.render(
            data,
            fields: [:type, :pnn, :pn, :psn, :ps, :dnn, :dn, :dsn, :ds, :ns, :nn, :alpha, :divs, :snps]
          )
  end

end
