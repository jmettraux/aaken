
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

  def cumulate(mod=0)

    (0..23)
      .inject({}) { |h, dc|
        h[dc] = @spread.inject(0) { |s, (k, v)|
          s = s + v if k.is_a?(Integer) && k >= (dc - mod)
          s }
        h }
  end

  def cumulate_percentage(mod=0)

    c = @spread[:count]

    cumulate(mod)
      .inject({}) { |h, (k, v)|
        h[k] = v.to_f / c * 100
        h }
  end

  protected

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
  #'2d10',
  #'1d20',
  #'2d20a1',
  #'2d20d1',
  #'2d20a1',
  #'3d10t2',
  #'3d7', '2d10', '1d20',
  #'4d7d3', '3d10d2', '2d20d1',
  #'3d6',
  '4d6a3', '4d6d3',
]
  .each do |s|
    puts "-" * 80
    d = Dice.new(s)
    #p d.s
    #p d.spread
    #p d.spread_percentage
    #puts "---"
    #p d.cumulate(0)
    #pp d.cumulate_percentage(0)
    #puts "---"
    #p d.cumulate(-1)
    #pp d.cumulate_percentage(-1)

    h = {}
    d.spread.inject(h) { |hh, (k, v)| (hh[k] ||= []) << v; hh }
    d.spread_percentage.inject(h) { |hh, (k, v)| (hh[k] ||= []) << v; hh }
    d.cumulate.inject(h) { |hh, (k, v)| (hh[k] ||= []) << v; hh }
    d.cumulate_percentage.inject(h) { |hh, (k, v)| (hh[k] ||= []) << v; hh }
    puts
    puts d.s
    h.keys.sort_by { |k| k.is_a?(Integer) ? ("%02d" % k) : k.to_s }.each do |k|
      puts [ k, *h[k] ].collect(&:to_s).join("\t")
    end
  end

