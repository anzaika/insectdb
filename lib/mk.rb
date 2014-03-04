module MK
  include Parallel

  def self.mk_formatted( query, exon_shift )

    mk100 = self.mk(query, exon_shift, 100)
    mk85  = self.mk(query, exon_shift, 85)
    puts "%tr"
    puts "\s\s%td\n\s\s#{mk100[:alphaNorm]}"
    puts "\s\s%td\n\s\s#{mk85[:alphaNorm]}"
    puts "\s\s%td\n\s\s#{mk100[:dnNorm]}"
    puts "\s\s%td\n\s\s#{mk100[:dsNorm]}"
    puts "\s\s%td\n\s\s#{mk100[:pnNorm]}"
    puts "\s\s%td\n\s\s#{mk85[:pnNorm]}"
    puts "\s\s%td\n\s\s#{mk100[:psNorm]}"
    puts "\s\s%td\n\s\s#{mk85[:psNorm]}"
    puts "%tr"
    puts "\s\s%td\n\s\s#{mk100[:dn]}"
    puts "\s\s%td\n\s\s#{mk100[:dnPerCent]}"
    puts "\s\s%td\n\s\s#{mk100[:ds]}"
    puts "\s\s%td\n\s\s#{mk100[:dsPerCent]}"
    puts "\s\s%td\n\s\s#{mk100[:pn]}"
    puts "\s\s%td\n\s\s#{mk100[:pnPerCent]}"
    puts "\s\s%td\n\s\s#{ mk85[:pn]}"
    puts "\s\s%td\n\s\s#{ mk85[:pnPerCent]}"
    puts "\s\s%td\n\s\s#{mk100[:ps]}"
    puts "\s\s%td\n\s\s#{mk100[:psPerCent]}"
    puts "\s\s%td\n\s\s#{ mk85[:ps]}"
    puts "\s\s%td\n\s\s#{ mk85[:psPerCent]}"
    puts "\s\s%td\n\s\s#{mk100[:synPoss]}"
    puts "\s\s%td\n\s\s#{mk100[:nonsynPoss]}"
    # puts "\s\s%td\n\s\s#{mk100[:lengthSum]}"
    # puts "\s\s%td\n\s\s#{Insectdb::Segment.exon_shift.to_s}"
    # puts "\s\s%td\n\s\s#{Insectdb::Snp.margin.to_s}"

  end

  # Execute MacDonald-Kreitman test for segments returned by query
  def self.mk( query, snp_margin )

    result =
      self.mapp(query, 12) do |s|
        self.dn_ds_pn_ps(s, snp_margin)
      end

    dn = result.map{ |h| h[:dn] }.reduce(:+)
    ds = result.map{ |h| h[:ds] }.reduce(:+)
    pn = result.map{ |h| h[:pn] }.reduce(:+)
    ps = result.map{ |h| h[:ps] }.reduce(:+)

    alpha = 1-((ds*pn)/(dn*ps))

    {
      :alpha100 => alpha.round(4),
      :dn => dn.round(4),
      :ds => ds.round(4),
      :pn => pn.round(4),
      :ps => ps.round(4),
    }

  end

  # Private: Return dn_ds_pn_ps values for this segment.
  #
  # snp_aaf_margin - Set the upper margin for SNP aaf ( ancestral allele
  #                  frequency) value. Default is 100%.
  #
  # Returns Hash.
  def self.dn_ds_pn_ps( segment, snp_aaf_margin = 100 )
    s = segment.snps.select { |e| e.aaf < snp_aaf_margin }.map(&:syn?)
    d = segment.divs.map(&:syn?)

    {
      :dn => d.count { |r| r.first == false },
      :ds => d.count { |r| r.first == true  },
      :pn => s.count { |r| r.first == false },
      :ps => s.count { |r| r.first == true  }
    }
  end


end
