require 'pty'
require 'pry'
require 'stringio'
require 'rspec_logfmt_formatter'

describe RspecLogfmtFormatter do
  let(:tmp_dir) { File.expand_path('../tmp', __dir__) }
  let(:formatter_output_path) { File.join(tmp_dir, 'rspec_logfmt.txt') }
  let(:output) { execute_example_spec }
  let(:formatter_output) do
    output
    File.read(formatter_output_path)
  end
  let(:formatter_arguments) { ['--format', 'RspecLogfmtFormatter', '--out', formatter_output_path] }

  def safe_pty(command, **pty_options)
    output = StringIO.new

    PTY.spawn(*command, **pty_options) do |r, _w, pid|
      r.each_line { |line| output.puts(line) }
    rescue Errno::EIO
      # Command closed output, or exited
    ensure
      Process.wait pid
    end

    output.string
  end

  def execute_example_spec
    command = ['bundle', 'exec', 'rspec', *formatter_arguments]

    safe_pty(command, chdir: File.expand_path('../example', __dir__))
  end

  context '$TEST_ENV_NUMBER is not set' do
    before { ENV.delete('TEST_ENV_NUMBER') } # Make sure this doesn't exist by default

    it 'correctly describes the test results', aggregate_failures: true do
      expect(formatter_output.match(/tests.name="(\w+)"/)[1]).to eql('rspec')
      expect(formatter_output.match(/tests.count="(\w+)"/)[1]).to eql('5')
      expect(formatter_output.match(/tests.skipped="(\w+)"/)[1]).to eql('1')
      expect(formatter_output.match(/tests.failures="(\w+)"/)[1]).to eql('3')
      expect(formatter_output.match(/tests.errors="(\w+)"/)[1]).to eql('0')
      expect(formatter_output.match(/tests.retries.count="(\w+)"/)[1]).to eql('1')
    end
  end

  context 'TEST_ENV_NUMBER is set' do
    around do |example|
      ENV['TEST_ENV_NUMBER'] = '2'
      example.call
    ensure
      ENV.delete('TEST_ENV_NUMBER')
    end

    it 'includes $TEST_ENV_NUMBER in the formatter_output name' do
      expect(formatter_output.match(/tests.name="(\w+)"/)[1]).to eql('rspec2')
    end
  end
end
