module MutationCount
class Leushkin

  def initialize(codon: codon, mutations: mutations)
    @cod = codon
    @muts = mutations
    @count = SynCount.new
  end

  def run
    build_result if passes_check?
    @count
  end

  private

  def build_result
    case check_pos_in_map
    when true  then @count.s += 1
    when false then @count.n += 1
    end
  end

  def check_pos_in_map
    case map[inn_pos]
    when 's' then true
    when 'n' then false
    when 'u' then nil
    end
  end

  def passes_check?
    only_one_mutation? && map
  end

  def only_one_mutation?
    @muts.size == 1
  end

  def map
    @map ||= @cod.syn_map
  end

  def inn_pos
    @cod.glob_to_int(@muts.first.pos)
  end

end
end
