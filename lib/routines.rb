module Routines

  def self.remove_unused_snps_and_divs

    Insectdb.each_chromosome do |name, q|

      Insectdb
        .mapp(Insectdb::Segment.where('chromosome = ?', q), 10){ |s| Range.new(s.start, s.stop).to_a }
        .reduce(:+)
        .tap do |a|
          Insectdb::Snp.delete_all(['chromosome = ? and position not in (?)', q, a])
          Insectdb::Div.delete_all(['chromosome = ? and position not in (?)', q, a])
        end

      'success'
    end

  end

  def self.per_segment_summary

    Insectdb::Snp.set_margin(85)

    Insectdb.mapp(Insectdb::Segment.coding, 10) do |s|
      {
        'segment_id' => s.id,
        'chromosome' => s.chromosome,
        'strand' => s.strand,
        'start' => s.start,
        'stop' => s.stop,
        'dn' => Insectdb::Div.count_at_poss(s.chromosome, s.poss('nonsyn')),
        'ds' => Insectdb::Div.count_at_poss(s.chromosome, s.poss('syn')),
        'pn' => Insectdb::Snp.count_at_poss(s.chromosome, s.poss('nonsyn')),
        'ps' => Insectdb::Snp.count_at_poss(s.chromosome, s.poss('syn'))
      }
    end

  end

  # Public: Generate a report for a set of segments
  #
  # query - The Enumerable with segments to be processed
  def self.summary_formatted( query, exon_shift )
    # Insectdb.reconnect
    # Insectdb::Segment.clear_cache
    Insectdb::Segment.set_shifts(exon_shift, 0)

    site_count =
      %W[syn nonsyn].map do |syn|
        %W[2L 2R 3L 3R X].map do |chr|
          query.where(:chromosome => chr)
               .map { |s| s.poss(syn).count }
               .reduce(:+)
        end.reduce(:+)
      end

    poly_data =
      Insectdb.mapp(%W[syn nonsyn]) do |syn|
        Insectdb.mapp(%W[2L 2R 3L 3R X]) do |chr|
          Insectdb::Snp.allele_freq_dist_at_poss(chr, query.map { |s| s.poss(syn) }.flatten)
        end.reduce{ |s,n| s.merge(n){ |key, a, b| a+b } }
      end

    div_data =
      Insectdb.mapp(%W[syn nonsyn]) do |syn|
        Insectdb.mapp(%W[2L 2R 3L 3R X]) do |chr|
          Insectdb::Div.count_at_poss(chr, query.map { |s| s.poss(syn) }.flatten)
        end.reduce(:+)
      end

    poly_data_formatted  =
      poly_data.reduce{|s,n| s.merge(n){|k,a,b| [a,b]}}
               .sort_by(&:first)
               .map { |v| v.last.join("\t") }
               .join("\n")
    div_data_formatted   = div_data.join("\t")
    site_count_formatted = site_count.join("\t")

    poly_data_formatted + "\n" +
    div_data_formatted  + "\n" +
    site_count_formatted
  end

  ########################################
  ############ Binding stuff #############
  ########################################

  def self.bind_divs_for_all_nucs( syn, scope )
    bind = Insectdb.bind

    syn_poss =
      Insectdb::Segment
        .send(scope)
        .where(:chromosome => '2L')
        .map { |s| s.poss(syn) }
        .flatten

    all_nuc_counts = %W[ A C G T ].map do |nuc|
      Insectdb.mapp(bind) do |bind_bin|
        Insectdb::Reference.count_nucs_at_poss('2L', bind_bin, nuc)
      end
    end

    div_nuc_counts =
      %W[ A C G T ].permutation(2).map do |nucs|
        Insectdb.mapp(bind) do |bind_bin|
          Insectdb::Div.count_at_poss_with_nucs('2L', bind_bin, nucs[1], nucs[0])
        end
      end

    result =
      div_nuc_counts
        .each_slice(3)
        .map(&:inn_sum)
        .map.with_index { |a,i| a.divide_by(all_nuc_counts[i]) }

    [result, div_nuc_counts, all_nuc_counts]
  end

  def self.divs_per_bin_for( syn, query )
    data = Insectdb.bind('insectdb/data/dm3_basepairs_2L_out')
    syn_poss = query.map { |s| s.poss(syn) }.flatten
    warn "Data loading complete"

    data.map do |poss|
      iposs = poss.isect(syn_poss)
      val = iposs.each_slice(10000)
                 .map { |s| Insectdb::Div.count_at_poss('2L', s) }
                 .sum
      iposs.count == 0 ? 0 : (val.to_f/iposs.count)
    end
  end

  def self.draw_counts_for( syn, query )
    data = Insectdb.bind('insectdb/data/dm3_basepairs_2L_out')
    syn_poss = query.map { |s| s.poss(syn) }.flatten

    res = data.map { |poss| poss.isect(syn_poss).count }
    res.map { |v| v.to_f/res.sum }
  end

end
