class SynCount

  attr_reader :s, :n

  def initialize(s: 0.0, n: 0.0)
    @s = s
    @n = n
  end

  def s=(value)
    @s = value.to_f.round(4)
  end

  def n=(value)
    @n = value.to_f.round(4)
  end

  def +(other)
    s_sum = (self.s + other.s).round(4)
    n_sum = (self.n + other.n).round(4)
    SynCount.new(s: s_sum, n: n_sum)
  end

  def to_s
    {syn: @s, nonsyn: @n}
  end

  def ==(other)
    (self.class == other.class) &&
    (@s == other.s) &&
    (@n == other.n)
  end

end
