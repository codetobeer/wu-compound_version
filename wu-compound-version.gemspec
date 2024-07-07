WU_VERSION = '0.0.1'
Gem::Specification.new do |s|
  s.name          = "wu-compound-version"
  s.version       = WU_VERSION
  s.authors       = ["Emanuele Caratti"]
  s.email         = %q{wiz@nowhere.to}
  s.date          = Time.now.strftime('%Y-%m-%d') #`date +%Y-%m-%d`
  s.summary       = "Class to handle complex version built from multiple SemVer"
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/codetobeer/wu-compound-version'
  s.description   = (<<~__DESC__)
    Helpers for XLS(x) read and create, via roo & write_xlsx
  __DESC__

  s.required_ruby_version = ['>= 2.7.0'] # On 3 could break...

  #s.executables = %w[ ]

  s.files = Dir['lib/wu/**/*.rb']
#  s.test_files = ["test/test_hola.rb"]
  s.require_paths = ["lib"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3
end
