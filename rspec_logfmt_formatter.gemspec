lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec_logfmt_formatter/version'

Gem::Specification.new do |s|
  s.name        = 'rspec_logfmt_formatter'
  s.version     = RspecLogfmtFormatter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Richard Vickerstaff'
  s.email       = ['developers@carwow.co.uk']
  s.homepage    = 'https://github.com/carwow/rspec_logfmt_formatter'
  s.summary     = 'RSpec formatter that honeycomb can read'
  s.description = ''
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.7.0'
  s.required_rubygems_version = '>= 2.0.0'

  s.files = Dir['lib/**/*', 'README.md', 'LICENSE']
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_path = 'lib'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'carwow_rubocop', '3.4.4'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'rspec-retry'

  s.add_dependency 'rspec-core', '>= 2', '< 4'
end
