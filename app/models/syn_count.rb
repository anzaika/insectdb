class SynCount

  attr_reader :s, :n

  def initialize(s: 0.0, n: 0.0)
    @s = s
    @n = n
  end

  def s=(value)
    @s = value.to_f
  end

  def n=(value)
    @n = value.to_f
  end

  def +(other)
    s_sum = (self.s + other.s).round(3)
    n_sum = (self.n + other.n).round(3)
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
