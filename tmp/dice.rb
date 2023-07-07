
# 1d20 + 1
# 2d20t1 + 1
# 2d20a1 + 1
# 2d20d1 + 1

class Dice

  attr_reader :s
  attr_reader :spread, :spread_percentage

  def initialize(s)

    @s = s
    m = s.match(/^(\d+)d(\d+)([tad]\d+)?$/)

    @cnt = m[1].to_i
    @die = m[2].to_i
    @adv = m[3]

    m = @adv && @adv.match(/^(.)(\d+)$/)
    @adv = m && [ m[1], m[2].to_i ]

    @spread = compute_spread
    @spread_percentage = compute_spread_percentage
  end

  def compute_spread

    d = (1..@die).to_a

    r = d; (@cnt - 1).times { r = r.product(d) }

    r
      .collect { |e|
        e = Array(e).flatten.sort
        if @adv
          e = (@adv[0] == 'a' || @adv[0] == 't') ? e.reverse : e
          e.take(@adv[1])
        else
          e
        end }
      .collect(&:sum)
      .inject({}) { |h, e| h[e] = (h[e] || 0) + 1; h }
      .tap { |h| h[:count] = h.values.sum }
  end

  def compute_spread_percentage

    c = @spread[:count]

    @spread.inject({}) { |h, (k, v)| h[k] = v.to_f / c * 100; h }
  end
end

[
  '1d20',
  '2d10',
  '2d20a1',
  '3d10t2',
]
  .each do |s|
    puts "-" * 80
    d = Dice.new(s)
    p d.s
    pp d.spread
    pp d.spread_percentage
  end

