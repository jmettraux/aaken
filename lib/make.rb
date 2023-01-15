
require 'yaml'
#require 'ostruct'
require 'rexml/document'


CONFIG =
  YAML.load_file('Config.yaml')
    .inject({}) { |h, (k, v)|
      #h[k] = v
      h[k.to_sym] = v
      h }
#pp CONFIG


Dir[File.join(__dir__, '*.rb')]
  .each do |pa|

    next if %w[ make.rb ].find { |e| pa.end_with?(e) }

    require(pa)
  end

def neutralize_name(s); s.gsub(/[^a-zA-Z0-9]/, '_'); end

