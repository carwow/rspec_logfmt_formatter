Gem::Specification.new do |s| # rubocop:disable Gemspec/RequireMFA
  s.name = "rspec_logfmt_formatter"
  s.version = "0.0.2.pre"
  s.platform = Gem::Platform::RUBY
  s.author = "Richard Vickerstaff"
  s.email = ["developers@carwow.co.uk"]
  s.homepage = "https://github.com/carwow/rspec_logfmt_formatter"
  s.summary = "RSpec formatter that honeycomb can read"
  s.description = ""
  s.license = "MIT"

  s.require_path = "lib"
  s.files = Dir["exe/*", "lib/**/*", "README.md", "LICENSE"]

  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.required_ruby_version = ">= 3.2"
  s.add_dependency "rspec-core", ">= 3.6", "< 4"
end
