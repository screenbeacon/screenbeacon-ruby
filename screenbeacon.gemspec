$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'screenbeacon/version'

spec = Gem::Specification.new do |s|
  s.name = 'screenbeacon'
  s.version = Screenbeacon::VERSION
  s.summary = 'Ruby bindings for the Screenbeacon API'
  s.description = 'Screenbeacon is a visual design testing service.'
  s.authors = ['Jordan Humphreys']
  s.email = ['jordan@screenbeacon.com']
  s.homepage = 'https://screenbeacon.readme.io'
  s.license = 'MIT'

  s.add_dependency('rest-client', '~> 1.4')
  s.add_dependency('json', '~> 1.8.1')

  s.add_development_dependency('mocha', '~> 0.13.2')
  s.add_development_dependency('shoulda', '~> 3.4.0')
  s.add_development_dependency('test-unit')
  s.add_development_dependency('rake')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
