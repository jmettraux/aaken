
#
# make_css.rb


def make_css

  n = CONFIG[:NAME_]

  File.open("out/html/#{n}.css", 'wb') do |f|

    f.write(File.read("src/css/_#{n}.css"))

    Dir['src/css/*.css'].each do |css|

      f.write(File.read(css)) unless css == "src/css/_#{n}.css"
    end
  end
end

