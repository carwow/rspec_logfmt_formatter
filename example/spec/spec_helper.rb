require 'rspec/retry'

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  config.around :each, :retry_spec do |ex|
    ex.run_with_retry retry: 2
  end

  config.around do |example|
    $stdout = StringIO.new
    $stderr = StringIO.new

    example.run

    example.metadata[:stdout] = $stdout.string
    example.metadata[:stderr] = $stderr.string

    $stdout = STDOUT
    $stderr = STDERR
  end
end
