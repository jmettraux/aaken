
def make_pdf

  h = {}

  h[:in] = "out/html/#{CONFIG[:NAME]}.html"
  h[:out] = "out/html/#{CONFIG[:NAME]}.pdf"
  make_chrome_pdf(h)

  h[:in] = "out/html/#{CONFIG[:NAME]}.pdf"
  h[:out] = "out/html/#{CONFIG[:NAME]}.stuffed.pdf"
  make_stuffed_pdf(h)

  h[:in] = "out/html/#{CONFIG[:NAME]}.stuffed.pdf"
  h[:out] = "out/html/#{CONFIG[:NAME]}.stapled.pdf"
  make_stapled_pdf(h)

  if sps = ENV['SAMPLE_PAGES']

    h[:in] = "out/html/#{CONFIG[:NAME]}.pdf"
    h[:out] = "out/html/#{CONFIG[:NAME]}.sample.pdf"
    h[:pages] = sps
    make_sample_pdf(h)

    h[:in] = "out/html/#{CONFIG[:NAME]}.sample.pdf"
    h[:out] = "out/html/#{CONFIG[:NAME]}.sample.stuffed.pdf"
    make_stuffed_pdf(h)

    h[:in] = "out/html/#{CONFIG[:NAME]}.sample.stuffed.pdf"
    h[:out] = "out/html/#{CONFIG[:NAME]}.sample.stapled.pdf"
    make_stapled_pdf(h)
  end

  h[:in] = "out/html/character_sheet.html"
  h[:out] = "out/html/character_sheet.pdf"
  make_chrome_pdf(h)

  h[:in] = "out/html/character_sheet_0.html"
  h[:out] = "out/html/character_sheet_0.pdf"
  make_chrome_pdf(h)
end

def make_chrome_pdf(h)

  cmd =
    h.inject(CONFIG[:to_pdf]) { |s, (k, v)| s.gsub(/\$\{#{k}\}/, v) }

  puts(cmd)
  system(cmd)
end

def count_pages(h)

  cmd = h.inject(CONFIG[:pdfinfo]) { |s, (k, v)| s.gsub(/\$\{#{k}\}/, v) }
  puts(cmd)
  m = `#{cmd}`.match(/Pages:\s+(\d+)/)

  m[1].to_i
end

def make_stuffed_pdf(h)

  h1 = h.dup
  pcount = count_pages(h)
  mod = pcount % 4; mod = 4 - mod if mod > 0

  p [ :pcount, pcount ]
  p [ :pcount, :mod, mod ]

  h1[:blanks] = ([ 'out/tmp/blank_a4.pdf' ] * mod).join(' ')

  cmd =
    h1.inject(CONFIG[:to_stuffed_pdf]) { |s, (k, v)| s.gsub(/\$\{#{k}\}/, v) }

  puts(cmd)
  system(cmd)
end

def make_stapled_pdf(h)

  pcount = count_pages(h)
  p [ :pcount, pcount ]
  p [ :array_pages, array_pages(pcount) ]
  h[:pages] = array_pages(pcount).collect(&:to_s).join(',')

  cmd =
    h.inject(CONFIG[:to_stapled_pdf]) { |s, (k, v)| s.gsub(/\$\{#{k}\}/, v) }

  puts(cmd)
  system(cmd)
end

def array_pages(count)

  middle = (count.to_f / 2).ceil

  a = []; (1..count)
    .each do |page|
      if page <= middle
        a << [ page, nil ]
      else
        a[-(page - middle)][1] = page
      end
    end

  a.each_with_index do |row, i|
    a[i] = a[i].reverse if i.even?
  end
#puts; puts "vvv"
#a.each { |row| p row }
#puts "^^^"

  a.flatten
end

def make_sample_pdf(h)

  cmd =
    h.inject(CONFIG[:to_stapled_pdf]) { |s, (k, v)| s.gsub(/\$\{#{k}\}/, v) }

  puts(cmd)
  system(cmd)
end

