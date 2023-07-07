
def increase(count, maxes)

  a, b = count.chars.collect(&:to_i)
  b = b + 1
  if b > maxes[1]
    a = a + 1
    b = 1
  end

  "#{a}#{b}"
end

dice = [ 6, 8 ]

os = []

os << '_roman_'; 4.times { os << '·' }
os << 'frankish'; 4.times { os << '·' }
os << 'gallic'; 4.times { os << '·' }
os << 'burgund'; 3.times { os << '·' }
os << 'lombard'; 2.times { os << '·' }
os << 'saxon'; 2.times { os << '·' }
os << 'briton'; 2.times { os << '·' }
os << 'a-saxon'; 0.times { os << '·' }
os << 'irish'; 0.times { os << '·' }
os << 'visigoth'; 3.times { os << '·' }
os << 'ostrogoth'; 0.times { os << '·' }
os << 'hun'; 0.times { os << '·' }
os << 'dane'; 0.times { os << '·' }
os << 'norwegian'; 0.times { os << '·' }
os << 'swede'; 0.times { os << '·' }
os << 'sami'; 0.times { os << '·' }
os << 'pict'; 0.times { os << '·' }
os << 'byzantine'; 0.times { os << '·' }
os << 'rus'; 0.times { os << '·' }
os << 'maghreb'; 0.times { os << '·' }
os << 'jewish'; 2.times { os << '·' }
os << 'arab'; 0.times { os << '·' }

#   <!-- .social-class -->
#   | d6d8 | origin    |
#   |:----:|:---------:|
#   | 11   | _roman_   |
#   | 12   | .         |
#   ...

number = '10'
m = - os.collect(&:length).max

puts "  <!-- .social-class -->"
puts "  | d#{dice[0]}d#{dice[1]} | origin        |"
puts "  |:----:|:-------------:|"
os.each do |o|
  number = increase(number, dice)
  puts "  |  %s  | %#{m}s |" % [ number, o ]
end
puts
puts "  <!-- os: #{os.length} / #{dice[0] * dice[1]} -->"

