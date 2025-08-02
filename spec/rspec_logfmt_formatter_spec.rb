require "pty"
require "stringio"
require "fileutils"
require "rspec_logfmt_formatter"

describe RspecLogfmtFormatter do
  let(:formatter_arguments) { ["--format", described_class.to_s, "--out", formatter_output_file] }
  let(:formatter_output_file) { File.join(File.expand_path("../tmp", __dir__), "rspec_logfmt.txt") }
  let(:formatter_output) { File.read(formatter_output_file) }
  let(:example_spec_output) { StringIO.new }
  let(:example_dir) { File.expand_path("../example", __dir__) }
  let(:tmp_dir) { File.expand_path("../tmp", __dir__) }

  after do |example|
    if example.exception
      puts "Example spec output below"
      puts example_spec_output.string
      puts "Example spec output above"
      if File.exist? formatter_output_file
        puts "Formatter output below"
        puts formatter_output
        puts "End formatter output"
      end
    end
  end

  def execute_example_spec
    FileUtils.rm_f formatter_output_file

    PTY.spawn("bundle", "exec", "rspec", *formatter_arguments, chdir: example_dir) do |r, _w, pid|
      r.each_line { |line| example_spec_output.puts(line) }
    rescue Errno::EIO
      # Command closed output, or exited
    ensure
      Process.wait pid
    end
  end

  it "correctly describes the test results", :aggregate_failures do
    execute_example_spec

    expect(formatter_output).to match(/tests\.count="5"/)
    expect(formatter_output).to match(/tests\.skipped="1"/)
    expect(formatter_output).to match(/tests\.failures="3"/)
    expect(formatter_output).to match(/tests\.errors="0"/)
    expect(formatter_output).to match(/tests\.retries="1"/)
  end

  it "collates" do
    collated = described_class.collate <<~TXT
      tests.count="2"
      tests.failures="1"
      tests.count="3"
      tests.failures="2"
      tests.skipped="1"
    TXT

    expect(collated).to eq <<~TXT.chomp
      tests.count="5"
      tests.failures="3"
      tests.skipped="1"
    TXT
  end
end
