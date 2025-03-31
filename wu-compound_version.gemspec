version = begin 
            require_relative './lib/wu/compound_version/version.rb'
            WU::CompoundVersion::VERSION
          rescue LoadError
            '0.0.1'
          end

Gem::Specification.new do |s|
  s.name          = "wu-compound-version"
  s.version       = version
  s.authors       = ["Emanuele Caratti"]
  s.email         = '103307189+codetobeer@users.noreply.github.com'
  s.date          = Time.now.strftime('%Y-%m-%d') #`date +%Y-%m-%d`
  s.summary       = "Class to handle complex version built from multiple SemVer"
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/codetobeer/wu-compound-version'
  s.description   = s.summary

  s.required_ruby_version = ['>= 2.7.0']

  #s.executables = %w[ ]

  s.files = Dir['lib/wu/**/*.rb']
#  s.test_files = ["test/test_hola.rb"]
  s.require_paths = ["lib"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3
end
