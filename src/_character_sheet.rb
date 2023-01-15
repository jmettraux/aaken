
require 'pp'
require 'yaml'
require 'ostruct'
require 'strscan'


class DiceDice
  attr_reader :d0, :d1
  def initialize(d0, d1)
    @d0 = d0
    @d1 = d1
    @current = [ 1, 1 ]
  end
  def to_s
    "d#{d0}d#{d1}"
  end
  def next
    r = "#{@current[0]}#{@current[1]}".to_i
    @current[1] += 1
    if @current[1] > d1
      @current[1] = 1
      @current[0] += 1
    end
    r
  end
end

class Character
  def initialize(h)
    @h = h
    cs = @h[:configurations] || []
    cs.each do |c|
      base = geti(:base_ac) || 10
      skill = geti(c[:skill]) || -2
      shields = geti(:shields) || -2
      dodge = geti(:dodge) || -2
      range = c[:range]
      c[:ac] =
        base + (range ? [ dodge ] : [ skill, dodge ]).max
      c[:acws] =
        base + (range ? [ dodge, shields ] : [ skill, dodge, shields ]).max
      c[:attack] = skill
      if ! range && skill != 0 && ! c[:damage].match?(/[-+]/)
        c[:damage] = "#{c[:damage]}#{skill > 0 ? '+' : ''}#{skill}"
      end
    end
    cs << {} while cs.length < 5
    @h[:configurations] = cs.collect { |c| OpenStruct.new(c) }
#PP.pp(@h, $stderr)
  end
  def method_missing(k)
    if m = k.to_s.match(/^(.+)(_[a-z]+)$/)
      send("get#{m[2]}", m[1].to_sym)
    else
      get(k)
    end
  end
  def body; meanup(str_tc, con_tc, dex_tc).to_s; end
  def soul; meanup(int_tc, wis_tc, cha_tc).to_s; end
  def physical; meanup(str_tc, con_tc).to_s; end
  def evasion; meanup(dex_tc, int_tc).to_s; end
  def mental; meanup(wis_tc, cha_tc).to_s; end
  def learning; meanup(int_tc, wis_tc).to_s; end
  def impulse; meanup(dex_tc, wis_tc).to_s; end
  def initiative; meandown(dex, wis).to_s; end
  def all; meanup(str_tc, con_tc, dex_tc, int_tc, wis_tc, cha_tc).to_s; end
  def get(k); geti(k).to_s; end
  def configurations; @h[:configurations]; end
  def knows?(n); @h[:spells] && @h[:spells].include?(n.to_s); end
  def base_ac; @h[:base_ac]; end
  protected
  def geti(k); @h[k.to_s.downcase.to_sym]; end
  def get_tc(k); (21 - @h[k.to_s.downcase.to_sym]).to_s rescue ''; end
  def get_dc(k); i = send(k).to_i; i > 0 ? (21 - i).to_s : ''; end
  def meanup(*args)
    geti(:str) ?
    (args.inject(0.0) { |r, a| r + a.to_f } / args.length).ceil :
    ''
  end
  def meandown(*args)
    geti(:str) ?
    (args.inject(0.0) { |r, a| r + a.to_f } / args.length).floor :
    ''
  end
  class << self
    def load(path)
      Character.new(YAML.load_file(path))
    end
  end
end
character = Character.load(ENV['AACHEN_CHAR_YAML']) rescue Character.new({})


hs = OpenStruct.new(
  page_width: '297mm', # A4
  page_height: '210mm', # A4
  #page_width: "#{297 - 2 * 4.24}mm", # A4   Brother margin: 4.23mm, 0.16in
  #page_height: "#{210 - 2 * 4.24}mm", # A4
  #page_width: '215.9mm', # US Letter
  #page_height: '279.4mm', # US Letter
  size_a: '14pt',
  mul_a: '1.15',
  title_face: 'trajan-pro-3, serif',
  #main_face: 'minion-pro, serif',
  main_face: 'EB Garamond, serif',
  sans_face: 'ff-scala-sans-pro, sans-serif',
  circle_side: '3.0rem',
  border_width: '0.3rem',
  box_border_width: '0.10rem',
  box_width: '2.1rem',
  box_height: '1.1rem',
)
hs.cs = hs.circle_side

style = %{
  @import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400;1,500;1,600;1,700;1,800&display=swap');
  /*
  @import url('https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,600;0,700;1,400;1,600;1,700&display=swap');
  @import url("https://use.typekit.net/aqv1anf.css");
  */

  /*@media print { @page { size: landscape } }*/
  @page {
    size: landscape;
    margin: 4.23mm;
    /*margin: 0px;*/
  }

  *, *::before, *::after { box-sizing: border-box; }

  html {

    font-family: #{hs.main_face};
    font-size: #{hs.size_a};
    line-height: #{hs.mul_a};
  }

  body {

    width: #{hs.page_width};
    min-height: #{hs.page_height};
    max-height: #{hs.page_height};

    padding: 4.23mm;

    /*padding: 4.23mm; / * Brother printable area.... */
    /*padding: 0.17in; / * Brother printable area.... */
  }

  .grey { color: grey; }

  .ability-circle, .save-circle, .skill-box, .character-name,
  .field, .cp.icon, .hp.icon, .conf-cell {
    position: relative;
  }

  .d {
    color: blue;
    position: absolute;
    left: 28%;
  }
  .hp .d, .cp .d {
    font-size: 120%;
    left: 42%;
    top: 21%;
  }
  .cp .d {
    top: 28%;
  }
  .character-name .d {
    left: 3rem;
    bottom: 0.15rem;
  }
  .field .d {
    left: 4rem;
    bottom: 0.1rem;
  }
  .ability-circle .d {
    top: 0.8rem;
  }
  .ability-diamond .d {
    top: 0.7rem;
    left: 1rem;
  }
  .save-circle .d {
    top: 0.8rem;
    left: 1rem;
  }
  .save-circle .dia + .d {
    left: 0.2rem;
    top: -1.0rem;
  }
  .save-circle.explanation .dia + .d {
    left: 0.2rem;
    top: -0.8rem;
  }
  .skill-box .d {
    left: 28%;
    top: -2px;
  }
  .conf-cell.ac .d {
    top: 0.6rem;
    left: 32%;
    font-size: 110%;
  }
  .conf-cell.weapon .d {
    left: 0.2rem;
    bottom: 0.2rem;
  }
  .conf-cell.range .d {
    left: 0;
    bottom: 0.3rem;
    font-size: 70%;
  }
  .conf-cell.attack .d {
    font-size: 110%;
    top: 1rem;
    left: 1.7rem;
  }
  .conf-cell.damage .d {
    font-size: 110%;
    top: 1rem;
    left: 0.7rem;
  }
  .save-square .d {
    top: -0.2rem;
    left: 0.05rem;
    color: #9999ee;
  }
  .explanation .d {
    color: grey;
    font-size: 70%;
  }

  .skill-box {
    padding: 0;
  }

  .page {

    position: relative;

    margin: 0;
/*border: 1px solid lightgrey;*/
  }

  .page-grid {
    display: grid;
    width: 100%;
    min-height: 100%;
    height: 100%;
    grid-template-columns: 1fr 1fr;
    column-gap: 1rem;
  }

  .subgrid {
    display: grid;
    row-gap: 0.3rem;
  }

  .left.subgrid {
    column-gap: 0.3rem;
    grid-template-columns: 1.4rem auto;
  }
  .right.subgrid {
    column-gap: 0.3rem;
    grid-template-columns: 1.4rem auto 1.4rem 70%;
  }

  .vlabel {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    justify-self: stretch;
    align-self: stretch;
    background-color: lightgrey;
    text-align: center;
  }

  .ability-grid {
    display: grid;
    width: 100%;
    height: 100%;
    place-items: center;
    z-index: 0;
    grid-template-columns: auto 6rem auto 4rem auto auto auto auto;
  }

  .a-label {
    font-size: 71%;
    padding-top: 0.2rem;
    padding-bottom: 0.2rem;
    color: grey;
  }

  .ability-label {
    justify-self: left;
    grid-row-end: span 2;
    margin-left: 0.4rem;
  }

  .save-label {
    padding-left: 0.1rem;
    justify-self: center;
    align-self: start;
    font-size: 70%;
    grid-row-end: span 2;
  }
  .explanation-label {
    color: grey;
    padding-left: 0.1rem;
    justify-self: right;
    align-self: center;
    font-size: 70%;
    grid-row-end: span 2;
    text-align: center;
    line-height: 1.0;
  }
  .explanation-label:after {
    content: '→';
  }
  .explanation-label.ass {
    align-self: start;
  }

  .initiative {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    font-size: 70%;
    justify-self: start;
    align-self: end;
    color: grey;
    text-align: center;
    margin-bottom: 1.4rem;
    margin-left: 0.71rem;
  }

  .ability-bground {
    background-color: lightgrey;
    grid-column-end: span 3;
    grid-row-end: span 2;
    width: 100%;
    height: #{hs.circle_side};
    margin-bottom: 0.1rem;
    border-radius: 3rem;
  }
  .ability-diamond {
    width: #{hs.circle_side};
    height: #{hs.circle_side};
    grid-row-end: span 2;
position: relative;
  }
  .ability-diamond .dia {
    border: 7px solid grey;
    background-color: white;
    width: #{hs.circle_side};
    height: #{hs.circle_side};
    position: absolute;
    transform: scale(0.6, 0.85) rotate(45deg);
  }
  .ability-diamond:nth-child(3n) .dia {
    left: 0.42rem;
  }
  .ability-diamond:nth-child(3n+1) .dia {
    left: -0.4rem;
  }
  .ability-diamond:nth-child(3n) .d {
    left: 1.4rem;
  }
  .ability-diamond:nth-child(3n+1) .d {
    left: 0.6rem;
  }
  .ability-circle {
    width: #{hs.circle_side};
    height: #{hs.circle_side};
    border-radius: #{hs.circle_side};
    border: #{hs.border_width} solid grey;
    background-color: white;
    z-index: 10;
    grid-row-end: span 2;
  }
  .ability-circle:nth-child(3n) {
    left: 0.8rem;
  }
  .ability-circle:nth-child(3n+2) {
    left: 0.4rem;
  }

  .save-circle {
    width: #{hs.circle_side};
    height: #{hs.circle_side};
    border-radius: #{hs.circle_side};
    border: #{hs.border_width} solid lightgrey;
    background-color: white;
    grid-row-end: span 2;
    position: relative;
  }
  .save-circle .dia {
    position: absolute;
    border: 7px solid lightgrey;
    width: 2.4rem;
    height: 2.4rem;
    transform: scale(0.6, 0.85) rotate(45deg);
    top: -1.6rem;
    left: -0.5rem;
    background-color: white;
  }

  .line {
    grid-row-end: span 2;
  }
  .line::after {
    content: '';
    width: 1.4rem;
    height: #{hs.border_width};
    display: inline-block;
    background-color: grey;
  }
  .ldown::after {
    width: 4.2rem;
    transform-origin: left;
    transform: rotate(20deg);
  }
  .lup::after {
    width: 4.2rem;
    transform-origin: left;
    transform: rotate(-20deg);
  }
  .ldown35::after {
    width: 5.6rem;
    transform-origin: left;
    transform: rotate(35deg);
    background-color: grey;
  }
  .lup35::after {
    width: 5.6rem;
    transform-origin: left;
    transform: rotate(-35deg);
    background-color: grey;
  }
  .learning::after {
    width: 4.7rem;
    background-color: lightgrey;
  }

  /* POINT GRID */

  .point-grid {
    display: grid;
    row-gap: 0.2rem;
  }

  .point-grid > * {
    justify-self: center;
  }

  .point-grid .info {
    align-self: end;
  }
  .point-grid .max {
    font-weight: bold;
  }

  .point-grid .hp img, .point-grid .cp img {
    height: 4.2rem;
  }
  .point-grid .ac img {
    height: 2.1rem;
  }

  /* NAME */

  .character-name {
    border-bottom: 1px solid grey;
  }

  .character-name .title {
    color: grey;
  }

  /* INFO GRID */

  .info-grid {
    display: grid;
    grid-template-columns: 60% auto;
  }

  .info-grid .field {
    font-size: 70%;
    color: grey;
    align-self: end;
    border-bottom: 1px solid grey;
    min-height: 1.2rem;
    max-height: 1.2rem;
  }

  .info-grid .picture {
    width: 100%;
    height: 100%;
    border: 1px solid grey;
  }

  /* SPELL GRID */

  .spell-grid {
    text-align: center;
  }
  .spell-grid .t {
    font-size: 60%;
    text-align: center;
    color: grey;
    border-bottom: 1px solid white;
    padding: 0 0.1em;
  }
  .spell-grid .t11:after {
    content: '';
    display: block;
  }
  .spell-grid .t .i {
    margin-right: 0.1em;
  }
  .spell-grid .t.underline {
    border-bottom: 1px solid blue;
  }

  /* CONFIGURATION GRID */

  .configuration-grid {
    display: grid;
  }
  .configuration-grid img {
    height: 3.5rem;
  }

  .conf-footer {
    color: grey;
    font-size: 70%;
    margin-top: 0.66rem;
  }
  .conf-footer.base {
    justify-self: center;
  }
  .conf-footer .ac {
    border-bottom: 1px solid white;
  }
  .conf-footer .ac.underline {
    border-bottom: 1px solid blue;
  }

  .conf-cell {
    align-self: end;
    justify-self: center;
  }

  .conf-cell.header2 {
    font-size: 60%;
    color: grey;
    text-align: center;
    align-self: center;
  }

  .conf-cell.vertical {
    writing-mode: vertical-lr;
    justify-self: stretch;
    align-self: stretch;
    background-color: lightgrey;
    text-orientation: mixed;
    text-align: center;
    padding-left: 0.5rem;
  }

  .conf-cell .input {
    width: 3rem;
    display: inline-block;
    border-bottom: 1px solid grey;
  }

  .conf-cell.weapon {
    padding-right: 0.3rem;
  }
  .conf-cell.weapon .input {
    width: 7.0rem;
  }
  .conf-cell.range .input {
    width: 4.9rem;
  }

  .conf-cell.attack {
    position: relative;
  }
  .conf-cell.attack .plus {
    position: absolute;
    top: 1.9rem;
    left: 0.4rem;
  }

  /* SKILL GRID */

  .skill-grid {
    display: grid;
  }

  .skill-tag {
    font-size: 70pt;
    font-weight: bold;
    color: #d0d0d0;
    z-index: -1;
    align-self: end;
  }

  .skill-label {
    height: #{hs.box_height};
    font-size: 11pt;
  }
  .skill-label.italic {
    font-style: italic;
  }
  .skill-label.veiled {
    font-style: italic;
    color: grey;
  }
  .skill-label .dice {
    font-size: 9pt;
    color: grey;
    width: 0.9rem;
    text-align: right;
    display: inline-block;
    margin-right: 0.3rem;
  }
  .skill-box {
    border: #{hs.box_border_width} solid grey;
    width: #{hs.box_width};
    height: #{hs.box_height};
    margin-bottom: 1px;
    position: relative;
  }
  .skill-box.attack {
    border-color: black;
  }
  .skill-box::after {
    content: '+';
    color: grey;
    display: inline-block;
    position: absolute;
    top: -0.1rem;
    left: 0;
  }
  .skill-note {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    font-size: 11pt;
    color: grey;
    align-self: start;
    justify-self: center;
    padding-right: 0.33rem;
  }

  .weapon-cat {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    justify-self: stretch;
    align-self: stretch;
    background-color: lightgrey;
    padding: 0;
    margin-right: 0.2rem;
    padding-right: 0.2rem;
    text-align: center;
    border-bottom: 3px solid white;
  }

  img.atk {
    /*height: 4.2rem;*/
    transform: rotate(270deg);
  }
  img.dmg {
    /*height: 4.2rem;*/
  }

  /* misc */

  .bold { font-weight: bold; }
  span.mean { font-size: 90%; }

  table.dctc {
    font-size: 9pt;
    line-height: 0.8;
    color: darkgrey;
    position: absolute;
    left: 45.8%;
    top: 1.55rem;
    border-collapse: collapse;
  }
  table.dctc .l {
    text-align: right;
  }
  /*table.dctc tr:nth-child(1) { border-bottom: 1px solid lightgrey; }*/
  table.dctc tr:nth-child(5) {
    border-bottom: 1px solid lightgrey;
  }
  table.dctc tr:nth-child(6) td {
    padding-top: 0.05rem;
  }
  /*table.dctc tr:last-child { border-top: 1px solid lightgrey; }*/
  table.dctc td {
    padding-top: 0.02rem;
    padding-left: 0;
    padding-right: 0;
  }
  table.dctc td.c {
    padding-left: 0.2rem;
    padding-right: 0.1rem;
  }

}.strip

#style += %{
#  .right.subgrid { display: none; }
#  .skill-grid { display: none; }
#  .vlabel { display: none; }
#}.strip if ENV['AACHEN_CSHEET_ABILITIES']

scripts =
  ENV['AACHEN_CSHEET_ABILITIES'] ? '<script src="h-1.2.0.min.js"></script>' :
  ''

puts %{
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>character sheet</title>
  <link href="normalize-8.0.1.css" rel="stylesheet" type="text/css" />
  <!-- meta name="viewport" content="width=device-width, initial-scale=1" /-->
  #{scripts}
  <style>
    #{style}
  </style>
</head>
<body>
}

def split_id_and_classes(s)

  id = nil
  cs = []

  ss = StringScanner.new(s || ''); while ! ss.eos?
    m = ss.scan(/[.#][-_a-zA-Z0-9]+/); break unless m
    m0 = m[0, 1 ]; m1 = m[1..-1]
    if m0 == '#'
      id = m1
    else
      cs << m1
    end
  end

  OpenStruct.new(id: id, classes: cs)
end

def set_origin(x, y); $x = x; $y = y; end; set_origin(0, 0)

def make(tag_name, *rest, &block)

  idc = rest.find { |e| e.is_a?(String) && e.match?(/^[.#]/) }; rest.delete(idc)
  x, y, xspan, yspan = rest.select { |e| e.is_a?(Integer) }
  text = rest.find { |e| e.is_a?(String) }
  opts = rest.find { |e| e.is_a?(Hash) }

  idc = split_id_and_classes(idc || '')

  styles = []
    #
  styles << "grid-column-start: #{$x + x}" if x
  styles << "grid-row-start: #{$y + y}" if y
  styles << "grid-column-end: span #{xspan}" if xspan
  styles << "grid-row-end: span #{yspan}" if yspan
    #
  style = opts && opts.delete(:style)
  styles << style if style

  print "<#{tag_name}"
  print " id=\"#{idc.id}\"" if idc.id
  print " class=\"#{idc.classes.join(' ')}\"" if idc.classes.any?
  print " style=\"#{styles.join('; ')}\"" if styles.any?
  opts.each { |k, v| print " #{k}=#{v.to_s.inspect}" } if opts
  print ">"
  print text if text
  block.call if block
  puts "</#{tag_name}>"
end

def div(*args, &block); make(:div, *args, &block); end
def span(*args, &block); make(:span, *args, &block); end
def img(*args); make(:img, *args); end

puts %{
<div class="page">
  <table class="dctc">
    <tr><td class="l">DC</td><td class="c">⇌</td><td class="r">TC</td></tr>
    <tr><td class="l"> 3</td><td class="c"> </td><td class="r">18</td></tr>
    <tr><td class="l"> 4</td><td class="c"> </td><td class="r">17</td></tr>
    <tr><td class="l"> 5</td><td class="c"> </td><td class="r">16</td></tr>
    <tr><td class="l"> 6</td><td class="c"> </td><td class="r">15</td></tr>
    <tr><td class="l"> 7</td><td class="c"> </td><td class="r">14</td></tr>
    <tr><td class="l"> 8</td><td class="c"> </td><td class="r">13</td></tr>
    <tr><td class="l"> 9</td><td class="c"> </td><td class="r">12</td></tr>
    <tr><td class="l">10</td><td class="c"> </td><td class="r">11</td></tr>
    <tr><td class="l">TC</td><td class="c">⇌</td><td class="r">DC</td></tr>
  </table>
  <div class="page-grid">
}

div('.left.subgrid', 1, 1) do

  div('.vlabel', 1, 1, '↑ Abilities');
  div('.vlabel', 1, 2, '↑ Skills');

  div('.ability-grid', 2, 1) do

    div('.a-label', 1, 1, '3d6')
    div('.a-label', 3, 1, 'Abi TCs')
    div('.a-label', 4, 1, 'circles are TCs / diamonds are DCs', 5)
    #div('.a-label', 10, 1, 'DEX<span class="mean">×</span>WIS')

    div('.a-label', 1, 14, 'Abi DC')
    div('.a-label', 3, 14, '21 - Abi DC', 2, { style: 'justify-self: left;' })
    div('.a-label', 4, 14, 'DC = 21 - TC and TC = 21 - DC', 5)

    div('.ability-bground', 1, 2)
    div('.ability-bground', 1, 4)
    div('.ability-bground', 1, 6)
    div('.ability-bground', 1, 8)
    div('.ability-bground', 1, 10)
    div('.ability-bground', 1, 12)

    %w[ str con dex int wis cha ].each_with_index do |abi, ai|
      dc = abi + '_dc'
      div('.ability-diamond', 1, (ai + 1) * 2) {
        div('.dia')
        span('.d.ability-dc', { 'data-key' => dc }, character.send(abi)) }
    end

    div('.ability-label', 2, 2, '<b>STR</b>ength')
    div('.ability-label', 2, 4, '<b>CON</b>stitution')
    div('.ability-label', 2, 6, '<b>DEX</b>terity')
    div('.ability-label', 2, 8, '<b>INT</b>elligence')
    div('.ability-label', 2, 10, '<b>WIS</b>dom')
    div('.ability-label', 2, 12, '<b>CHA</b>risma')

    %w[ str con dex int wis cha ].each_with_index do |abi, ai|
      tc = abi + '_tc'
      div('.ability-circle', 3, (ai + 1) * 2) {
        span('.d.ability-tc', { 'data-key' => tc }, character.send(tc)) }
    end

    div('.save-circle', 4, 4) {
      span('.d', { 'data-key' => 'body_tc' }, character.body)
      div('.dia')
      span('.d', { 'data-key' => 'body_dc' }, character.body_dc) }
    div('.save-circle', 4, 10) {
      span('.d', { 'data-key' => 'soul_tc' }, character.soul)
      div('.dia')
      span('.d', { 'data-key' => 'soul_dc' }, character.soul_dc) }
    div('.save-label', 4, 6, 'Body')
    div('.save-label', 4, 12, 'Soul')

    div('.save-circle', 5, 3) {
      span('.d', { 'data-key' => 'physical_tc' }, character.physical)
      div('.dia')
      span('.d', { 'data-key' => 'physical_dc' }, character.physical_dc) }
    div('.save-circle', 5, 7) {
      span('.d', { 'data-key' => 'evasion_tc' }, character.evasion)
      div('.dia')
      span('.d', { 'data-key' => 'evasion_dc' }, character.evasion_dc) }
    div('.save-circle', 5, 11) {
      span('.d', { 'data-key' => 'mental_tc' }, character.mental)
      div('.dia')
      span('.d', { 'data-key' => 'mental_dc' }, character.mental_dc) }
    div('.save-label', 5, 5, 'Physical')
    div('.save-label', 5, 9, 'Evasion')
    div('.save-label', 5, 13, 'Mental')

    div('.save-circle', 6, 9) {
      span('.d', { 'data-key' => 'learning_tc' }, character.learning)
      div('.dia')
      span('.d', { 'data-key' => 'learning_dc' }, character.learning_dc) }
    div('.save-label', 6, 11, 'Learning')

    div('.initiative', 7, 1, 'INI modifier<br/>is Impulse DC →', 1, 7)

    div('.save-circle', 7, 8) {
      span('.d', { 'data-key' => 'impulse_tc' }, character.impulse)
      div('.dia')
      span('.d', { 'data-key' => 'impulse_dc' }, character.impulse_dc) }
    div('.save-label', 7, 10, 'Impulse')

    div('.save-circle', 8, 7) {
      span('.d', { 'data-key' => 'all_tc' }, character.all)
      div('.dia')
      span('.d', { 'data-key' => 'all_dc' }, character.all_dc) }
    div('.save-label.grey', 8, 9, 'all')

    div('.save-circle.explanation', 8, 12) {
      span('.d', 'TC')
      div('.dia')
      span('.d', 'DC') }
    div('.explanation-label', 6, 11, 'defend', 2)
    div('.explanation-label', 6, 12, 'transcend', 2)
  end

  div('.skill-grid', 2, 2) do

    div('.skill-tag', 1, 1, 2, 5, 'G')

    sd = DiceDice.new(4, 8)

    j = 0
    %w{
      Administer Build Connect Cook Exert Fish Gather Grow Heal Herd Hunt Lead
      Log Negotiate Perform Pray Read Ride Sail
      #Know #Notice #Craft #Sneak #Connect
    }
      .select { |k|
        k[0, 1] != '#' }
      .each_with_index do |k, i|
        next if k == 'skip'
        div('.skill-label', 1, 1 + i) do
          span('.dice', sd.next.to_s)
          span('.name', k)
        end
        div('.skill-box', 2, 1 + i) { span('.d', character.get(k)) }
        j = 1 + i
      end

    %w{
      Scout Spy Steal Swim Trade Travel
      #---
      _Craft
      _Know
      _
      _
      _
      _
    }
      .select { |k|
        k[0, 1] != '#' }
      .each_with_index do |k, i|
        next if k == '---'
        it, k = k.match(/^(_+)(.+)$/) ? [ $1, $2 ] : [ false, k ]
        klas = ''
        klas = klas + '.veiled' if it
        klas = klas + '.grey' if k == '_'
        k = (k == '_') ? '_________' : k
        div('.skill-label' + klas, 3, 1 + i) do
          d = sd.next.to_s
          d = sd.to_s if d == '47'
          span('.dice', d)
          span('.name', k)
        end
        div('.skill-box', 4, 1 + i) { span('.d', character.get(k)) }
      end

    %w{
      Throw
      Wrap
      Bind
      Feel
      Soak
      Radiate
    }
      .select { |k|
        k[0, 1] != '#' }
      .each_with_index do |k, i|
        next if k == '---'
        it, k = k.match(/^_(.+)$/) ? [ true, $1 ] : [ false, k ]
        klas = ''
        klas = klas + '.italic' if it
        klas = klas + '.grey' if k == '_'
        k = (k == '_') ? '_________' : k
        div('.skill-label' + klas, 3, 14 + i) do
          span('.dice', (i + 1).to_s)
          span('.name', k)
        end
        div('.skill-box', 4, 14 + i) { span('.d', character.get(k)) }
      end

    div('.skill-tag', 3, 13, 2, 5, 'M')

    t = [
      'skills start at +0, but default to -2, max is char level + 1',
      '1d20 + skill ≥ some TC'
    ].join('<br/>')
    div('.skill-note', 5, 1, t, 1, 16)

    j = 1
    %w{
      _Bows _Crossbows _Slings _Javelins --- Throw
      ---
      #Slash _Axes* _Maces* _Staves* _Spears* _Swords* _Knives* ---
      Punch Grapple
      ---
      _Shields
      Dodge
    }
      .select { |k|
        k[0, 1] != '#' }
      .each_with_index do |k, i|
        next if k == '---'
        it, k = k[0, 1] == '_' ? [ true, k[1..-1] ] : [ false, k ]
        at, k = k[-1, 1] == '*' ? [ true, k[0..-2] ] : [ false, k ]
        div('.skill-label' + (it ? '.italic' : ''), 7, 1 + i) do
          span('.dice', j.to_s)
          span('.name', k)
          j = j + 1
        end
        div('.skill-box' + (at ? '.attack' : ''), 8, 1 + i) {
          span('.d', character.get(k)) }
      end
    div('.skill-tag', 7, 1, 'F', 2, 5)

    div('.weapon-cat', 6, 1, '↑ ranged', 1, 6)
    div('.weapon-cat', 6, 8, '↑ melee', 1, 9)
  end
end

div('.right.subgrid', 2, 1) do

  div('.character-name', 2, 1, 3, 1) do
    div('.title', 'name')
    div('.d', character.name)
  end

  div('.point-grid', 2, 2) do

    div('.hp.info.max', 1, 1, 2, 1, 'HP max')
    div('.hp.icon', 1, 2, 2, 1) do
      img(src: 'heart.svg')
      span('.d', character.hp)
    end
  end
  div('.point-grid', 2, 3) do
    div('.cp.info.max', 1, 3, 2, 1, 'CP max')
    div('.cp.icon', 1, 4, 2, 1) do
      img(src: 'drop.svg')
      span('.d', character.cp)
    end
  end

  div('.info-grid', 4, 2, 1, 2) do

    div('.picture', 2, 1, 1, 7)

    j = -1
    [ 'player', 'level', 'class', 'background', 'origin', 'religion' ]
      .each_with_index do |k, i|
        j = i
        #k = '&nbsp;' if k == ''
        div('.field', k, 1, 1 + i) { span('.d', character.get(k)) }
      end
    j = j + 2
    [ 'appearance', '', '', 'traits (p12-13)', '', '', 'languages', 'scars', '' ]
      .each_with_index do |k, i|
        k = '&nbsp;' if k == ''
        div('.field', k, 1, j + i, 2, 1) { span('.d', character.get(k)) }
      end
  end

  div('.spell-grid', 2, 4, 3, 1) do
    %w[
      Amber Blue Coal Copper Gold Night
      Quartz Red Scarlet Silver Turquoise Faery
    ].each_with_index do |n, i|
      #div('.colour', 1 + (i * 2), 1, 2, 1) do
        span(".t.colour.t#{i}" + (character.knows?(n) ? '.underline' : '')) do
          span('.i', "#{1 + i}"); span('.n', n)
        end
      #end
    end
    %w[
      Arrow Ball Crown Disk Finger Flail
      Hand Hut Net Pole Powder Shield
    ].each_with_index do |n, i|
      #div('.form', 2 + (i * 2), 2, 2, 1) do
        span('.t.form' + (character.knows?(n) ? '.underline' : '')) do
          span('.i', "#{1 + i}"); span('.n', n)
        end
      #end
    end
  end

  div('.configuration-grid', 2, 5, 3, 1) do

    div('.conf-cell.header', 2, 1, 'AC', 2, 1)
    div('.conf-cell.header', 4, 1, 'Weapon')
    div('.conf-cell.header', 5, 1, 'Range')
    div('.conf-cell.header', 6, 1, 'Attack')
    div('.conf-cell.header', 7, 1, 'Damage')

    div('.conf-cell.header2', 2, 2, 'base AC + best of<br/>Dodge, Shield or <i>F Skill</i>', 2, 1)
    div('.conf-cell.header2', 2, 3, 'w/o shield')
    div('.conf-cell.header2', 3, 3, 'with shield')

    div('.conf-cell.header2', 5, 2, 'ft / m / sq')
    div('.conf-cell.header2', 6, 2, 'F Skill')
    div('.conf-cell.header2', 7, 2, 'Dice<br/>+ F Skill if melee')

    4.times do |y|
      div('.conf-cell.ac', 2, 4 + y) {
        img('.ac', src: 'shield-lightgrey.svg')
        span('.d', character.configurations[y].ac.to_s) }
      div('.conf-cell.ac', 3, 4 + y) {
        img('.ac', src: 'shield-grey.svg')
        span('.d', character.configurations[y].acws.to_s) }
      div('.conf-cell.weapon', 4, 4 + y) {
        span('.input', '')
        span('.d', character.configurations[y].weapon) }
      div('.conf-cell.range', 5, 4 + y) {
        span('.input', '')
        span('.d', character.configurations[y].range) }
      div('.conf-cell.attack', 6, 4 + y) {
        span('.plus', '+'); img('.atk', src: 'triangle.svg')
        span('.d', character.configurations[y].attack.to_s) }
      div('.conf-cell.damage', 7, 4 + y) {
        img('.dmg', src: 'hex.svg')
        span('.d', character.configurations[y].damage) }
    end

    div('.conf-footer.base', 2, 8, 'base AC:')
    div('.conf-footer', 3, 8, 6, 1) {
      [ 'no armour 10', 'gambeson 12', 'mail shirt 14', 'mail hauberk 16' ]
        .each do |a|
          n = a.match(/(\d+)/)[1].to_i
          span('.ac' + (character.base_ac == n ? '.underline' : ''), a)
          span('.slash', '/') unless a.match(/hauberk/)
        end
    }
  end

  div('.vlabel', 1, 1, '&nbsp;')
  div('.vlabel', 1, 2, '↑ Hit Points')
  #div('.vlabel', 1, 3, 'Cast Points ↑ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Spells ↑', 1, 2)
  div('.vlabel', 1, 3, '↑ Cast Points', 1, 2)
  div('.vlabel', 3, 2, '↑ Info', 1, 2)
  #div('.vlabel', 1, 3, '&nbsp;')
  div('.vlabel', 1, 5, '↑ Configurations')
end

puts %{
  </div> <!-- .page-grid -->
</div> <!-- .page -->
}

#  .right.subgrid { display: none; }
#  .skill-grid { display: none; }
#  .vlabel { display: none; }
puts %{
  <div class="ability-dialog hidden">
    <input class="score" type="text" />
    <input class="ok" type="submit" value="OK" />
  </div>
  <style>
    .hidden {
      display: none;
    }
    .ability-dialog {
      border: 2px solid black;
      padding: 2rem;
      position: absolute;
      top: 3rem;
      left: 6rem;
      background-color: lightgrey;
    }
    .ability-dialog input.score {
      width: 3rem;
    }
    .ability-dialog input.ok {
      width: 3rem;
    }
  </style>
  <script>
    H.setText('title', 'ability computer');

    H.remove('.right.subgrid');
    H.remove('.skill-grid');
    H.remove('.vlabel');

    var clog = console.log;

    var ade = H.elt('.ability-dialog');

    H.on(
      '.ability-diamond',
      'click',
      function(ev) {
        ade._target = H.elt(ev.target, '^.ability-diamond');
        H.elt(ade, 'input.score').value = H.text(ade._target, '.d');
        H.unhide(ade);
        H.elt(ade, 'input.score').focus(); });
    H.on(
      '.ability-dialog input.ok',
      'click',
      function(ev) {
        var v = H.vali(ade, 'input.score');
        if (typeof v !== 'number') return;
        if (v < 1 || v > 21) return;
        H.elt(ade._target, '.d').textContent = '' + v;
        H.hide(ade);
        recompute();
      });
    H.on(
      '.ability-dialog input.score',
      'keyup',
      function(ev) {
        if (ev.code === 'Enter') H.elt('.ability-dialog input.ok').click();
      });

    H.on(
      '.save-circle.explanation',
      'click',
      function(ev) {
        var max = 18; var min = 3;
        abis.forEach(function(abi) {
          set(abi + '_dc', Math.floor(Math.random() * (max - min + 1) + min));
        });
        recompute();
      });

    var abis = [ 'str', 'con', 'dex', 'int', 'wis', 'cha' ];
    var dcs = {};

    var set = function(key, val) {
      dcs[key] = val;
      H.setText(`[-key="${key}"]`, val);
    };

    var mean_tc = function() {
      var sum = Array.from(arguments).reduce(
        function(r, e) { return r + e; },
        0);
      return Math.ceil(sum / arguments.length);
    };
    var inv = function(i) {
      return 21 - i;
    };

    var recompute = function() {

      dcs = H.reduce(
        '.d.ability-dc',
        function(h, e) { h[H.att(e, '-key')] = H.texti(e); return h; },
        {});

      abis.forEach(function(abi) {
        set(abi + '_tc', inv(dcs[abi + '_dc']));
      });

      set('body_tc', mean_tc(dcs.str_tc, dcs.con_tc, dcs.dex_tc));
      set('body_dc', inv(dcs.body_tc));

      set('soul_tc', mean_tc(dcs.int_tc, dcs.wis_tc, dcs.cha_tc));
      set('soul_dc', inv(dcs.soul_tc));

      set('physical_tc', mean_tc(dcs.str_tc, dcs.con_tc));
      set('physical_dc', inv(dcs.physical_tc));

      set('evasion_tc', mean_tc(dcs.dex_tc, dcs.int_tc));
      set('evasion_dc', inv(dcs.evasion_tc));

      set('mental_tc', mean_tc(dcs.wis_tc, dcs.cha_tc));
      set('mental_dc', inv(dcs.mental_tc));

      set('learning_tc', mean_tc(dcs.int_tc, dcs.wis_tc));
      set('learning_dc', inv(dcs.learning_tc));

      set('impulse_tc', mean_tc(dcs.dex_tc, dcs.wis_tc));
      set('impulse_dc', inv(dcs.impulse_tc));

      set('all_tc', mean_tc(
        dcs.str_tc, dcs.con_tc, dcs.dex_tc,
        dcs.int_tc, dcs.wis_tc, dcs.cha_tc));
      set('all_dc', inv(dcs.all_tc));
    };

    H.forEach('.d.ability-dc', function(e) { e.textContent = 10; });
    recompute();
  </script>
} if ENV['AACHEN_CSHEET_ABILITIES']

puts %{
</body>
</html>
}

