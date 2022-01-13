Gem::Specification.new do |s|
  s.name        = "rspec_logfmt_formatter"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.author      = ""
  s.email       = ""
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  s.license     = ""

  s.required_ruby_version = ">= 2.3.0"
  s.required_rubygems_version = ">= 2.0.0"

  s.add_dependency "rspec-core", ">= 2", "< 4"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"

  s.files        = Dir["lib/**/*", "README.md", "LICENSE"]
  s.require_path = "lib"
end
