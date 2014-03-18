module SeedFourthStage
  class Seeder
    include Constants

    SEPARATOR = ';'

    def run
      segments
      mrnas
      genes
      mrnas_segments
      genes_mrnas
    end

    def segments
      _exec_and_format(:segments) do |l|
        Segment.create! do |r|
          r.id         = l[0].to_i
          r.chromosome = CHROMOSOMES[l[1]]
          r.start      = l[2].to_i
          r.stop       = l[3].to_i
          r.type       = l[4]
          r.length     = l[3].to_i - l[2].to_i
        end
      end
    end

    def mrnas
      _exec_and_format(:mrnas) do |l|
        Mrna.create! do |r|
          r.id         = l[0].to_i
          r.chromosome = CHROMOSOMES[l[1]]
          r.strand     = l[2]
          r.start      = l[3].to_i
          r.stop       = l[4].to_i
        end
      end
    end

    def genes
      _exec_and_format(:genes) do |l|
        Gene.create! do |r|
          r.id         = l[0].to_i
          r.flybase_id = l[1]
        end
      end
    end

    def mrnas_segments
      _exec_and_format(:mrnas_segments) do |l|
        MrnasSegments.create!(
          :mrna_id    => l[0].to_i,
          :segment_id => l[1].to_i
        )
      end
    end

    def genes_mrnas
      _exec_and_format(:genes_mrnas) do |l|
        GenesMrnas.create!(
          :mrna_id => l[0].to_i,
          :gene_id => l[1].to_i
        )
      end
    end

    def _exec_and_catch_errors( path, &block )
      errors = []
      File.open(path,'r') do |f|
        f.lines.each_with_index do |l, ind|
          begin
            l = l.chomp.split(SEPARATOR)
            block.call(l)
          rescue => e
            errors.push({
              :line => ind + 1,
              :content => l.join(" | "),
              :error => e
            })
          end
        end
      end
      errors
    end

    def _exec_and_format( sym, &block )
      printf "Seeding #{sym.to_s.capitalize}... "

      start = Time.now
      errors = _exec_and_catch_errors(SEEDS[sym], &block)
      time = (Time.now - start).round

      puts "took #{time} sec"
      puts "Errors: #{errors.size}"
      puts ''
      errors.each do |e|
        puts "When processing line #{e[:line]}:"
        puts "-> #{e[:content]}"
        puts "Reason:"
        puts "-> #{e[:error].inspect}"
        puts ""
      end
    end

  end
end
