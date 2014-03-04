module Insectdb

  CHROMOSOMES = {'2R' => 0,
                 '2L' => 1,
                 '3R' => 2,
                 '3L' => 3,
                 'X'  => 4}

  def self.each_chromosome(&block)

    result = {}

    Insectdb::CHROMOSOMES.each do |name, val|
      puts "Processing " + name.to_s + " chromosome"
      result[name] = block.call(name, val)
    end

    result

  end

  def self.reconnect
    ActiveRecord::Base.connection.reconnect!
  rescue PG::Error => e
    warn "Failed to connect, will try again in a second"
    sleep(1)
    retry
  end

  # Public: Execute map in parallel processes on array.
  def self.mapp( array, processes = 8, &block )
    res =
      Parallel.map(array, :in_processes => processes) do |el|
        ActiveRecord::Base.connection.reconnect!
        block.call(el)
      end
    self.reconnect
    return res
  end

  def self.peach( array, processes = 8, &block )
    Parallel.each(array, :in_processes => processes) do |el|
      ActiveRecord::Base.connection.reconnect!
      block.call(el)
    end
    self.reconnect
  end

  def self.bench(&block)
    loop do
      a = block.call
      sleep(3)
      puts (block.call-a)
    end
  end

  # Public: Parse the file with binding data.
  #
  # The source file should have two columns separated by a comma:
  #   1,0.01
  #   2,3
  #   3,0.08
  #   5,0.12
  #
  # The first column is a coordinate on the chromosome,
  # while the second one represents the computed propability of nucleotide at this
  # position binding to another one. This value should not be considered as true probability but more
  # of a weight as long as it belongs to [0,inf).
  #
  # Positions are clustered by the value of their weight into the following groups:
  # [0,0.1) [0.1,0.2) ... until the last non-empty group
  #
  # Returns: Array of Arrays
  def self.bind
    data =
      File.open(Insectdb::Config.path_to(:bind))
          .lines
          .map{ |li| l=li.chomp.split(","); l[0]=l[0].to_i; l[1]=l[1].to_f; l }
          .sort_by(&:last)

    holder = [[]]
    prev = 0
    ind = 0

    data.each do |b|
      (ind+=1; holder << []) if (prev != (nxt = (b.last*10).to_i))
      holder[ind] << b.first
      prev = nxt
    end

    holder
  end

  def self.aloha( arr, syn, query, filename )
    File.open(filename, 'a') do |f|
      f << arr.join("-")
      f << "\t"
      f << self.divs_with_nucs(syn, query, arr[1], arr[0])[2]
      f << "\n"
    end
  end

  # @param [String] syn 'syn' or 'nonsyn'
  # @param [ActiveRecord::Relation] query Insectdb::Segment.alt
  def self.freqs( syn, query )
    spread =
      Insectdb.mapp(query, 16){|s| s.freqs_at(s.poss(syn))}
              .flatten
              .reduce(Hash.new(0)){|h,v| h[v]+=1;h}
              .sort_by(&:first)
    sum = spread.map(&:last).inject(:+)
    spread.map{|a| (a[1] = a[1].to_f/sum);a }
  end

  def self.pn_ps_dn_ds_for( query )
    s = query.map(&:count_syn_sites).reduce(:+)
    n = query.map(&:count_nonsyn_sites).reduce(:+)

    self.mapp(query){|seg| [seg.pn_ps, seg.dn_ds].flatten }
        .compact
        .reduce([0,0,0,0]){|s,n| s.map.with_index{|v,ind| v+n[ind]} }
        .map.with_index{|v,ind| ind%2==0 ? v/n : v/s}
  end

  def self.divs_bind( path )
    bind = self.bind(path).map(&:first)
    bind = bind.each_slice(bind.size/100).to_a
    self.mapp((0..99).to_a, 4){|i| Div.count('2L', bind[i]) }
  end
end
