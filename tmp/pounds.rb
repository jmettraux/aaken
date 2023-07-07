
start = 12
inc = 2
max = 150
ptk = 0.453592

s4pre = nil
s6pre = nil

puts '  | *4 | lb  | kg    | *6 |'
puts '  |---:|----:|------:|---:|'
  #
loop do
  s4 = start / 4; s4 = (s4 == s4pre || s4 < 3 || s4 > 18) ? '  ' : '%2d' % s4
  s6 = start / 6; s6 = (s6 == s6pre || s6 < 3 || s6 > 18) ? '  ' : '%2d' % s6
  s4pre = start / 4
  s6pre = start / 6
  puts "  | %s | %3d | %#5.1f | %s |" % [ s4, start, start * ptk, s6 ]
  start += inc
  break if start > max
end

