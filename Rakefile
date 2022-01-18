require 'bundler/gem_tasks'
task default: :spec

desc "Upload to rubygems"
task upload: :build do
  # Check if tag with v#{RspecLogfmtFormatter::VERSION} version exists, if so, return with error

  if tag_exists?(current_tag_name)
    puts "Tag exists, did you run rake increase_revision_number after merging with master?"
    exit 1
  end

  create_tag(current_tag_name)
  Rake::Task[:release].invoke
end

desc "Increase the revision number"
task :increase_revision_number do
  version_file = "lib/rspec_logfmt_formatter/version.rb"
  file_content = File.read(version_file)
  rule = /(\d+\.\d+\.)(\d+)/
  new_revision_number = rule.match(file_content)[2].to_i + 1
  new_file_content = file_content.sub(rule, '\1' + new_revision_number.to_s)

  File.open(version_file, 'w') { |file| file.write(new_file_content) }

  sh 'bundle install'
end

def tag_exists?(tag_name)
  result = `git tag | grep #{tag_name}`.strip
  result == tag_name
end

def create_tag(tag_name)
  sh "git tag -a #{tag_name} -m \"Released version #{tag_name}\""
  sh "git push origin #{tag_name}"
end

def current_tag_name
  "v#{RspecLogfmtFormatter::VERSION}"
end