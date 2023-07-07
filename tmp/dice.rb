
# 1d20 + 1
# 2d20t1 + 1
# 2d20a1 + 1
# 2d20d1 + 1

class Dice

  attr_reader :s

  def initialize(s)

    @s = s
    m = s.match(/^(\d+)d(\d+)([tad]\d+)?(\s*[-+]\s*\d+)?$/)

    @cnt = m[1].to_i
    @die = m[2].to_i
    @adv = m[3]
    @mod = m[4]

    m = @adv && @adv.match(/^(.)(\d+)$/)
    @adv = m && [ m[1], m[2].to_i ]
  end

  def spread

    d = (1..@die).to_a

    r = d; (@cnt - 1).times { r = r.product(d) }

    r
      .collect { |e|
        e = Array(e).sort
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
end

[
  '1d20',
  '2d10',
  '2d10 + 1',
  '2d10 - 1',
  '2d20a1 - 1'
]
  .each do |s|
    puts "-" * 80
    d = Dice.new(s)
    p d.s
    p d
    p d.spread
  end

