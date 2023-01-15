
#
# make_csheet.rb


def do_make_csheet(suffix='')

  system(
    "convert out/html/csheet#{suffix}.png " +
    "-trim out/html/csheet_trimmed#{suffix}.png")

  geom =
    `identify -verbose out/html/csheet_trimmed#{suffix}.png | grep Geometry`
  m = geom.match(/ (\d+)x(\d+)/)
  w = m[1].to_i
  h = m[2].to_i
  w2 = w * 0.52
  h = h * 1.1 # :-(

  system(
    "convert out/html/csheet_trimmed#{suffix}.png " +
    "-crop #{w2}x#{h}+0+0 -trim out/html/csheet_left#{suffix}.png")
  system(
    "convert out/html/csheet_trimmed#{suffix}.png " +
    "-crop #{w2}x#{h}+#{w2}+0 -trim out/html/csheet_right#{suffix}.png")

  system(
    "convert out/html/csheet_trimmed#{suffix}.png " +
    "-crop #{w2}x#{h / 2}+0+0 -trim out/html/csheet_abilities#{suffix}.png")
end

def make_csheet

  do_make_csheet()
  do_make_csheet('_0')
end

