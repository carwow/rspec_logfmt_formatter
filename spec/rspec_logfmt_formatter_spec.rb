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
  let(:example_env) { {"RSPEC_LOGFMT_SLOW_FILE_THRESHOLD_MS" => "200", "TEST_ENV_NUMBER" => nil, "CIRCLE_NODE_INDEX" => nil} }

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

    PTY.spawn(example_env, "bundle", "exec", "rspec", *formatter_arguments, chdir: example_dir) do |r, _w, pid|
      r.each_line { |line| example_spec_output.puts(line) }
    rescue Errno::EIO
      # Command closed output, or exited
    ensure
      Process.wait pid
    end
  end

  it "correctly describes the test results", :aggregate_failures do
    execute_example_spec

    expect(formatter_output).to match(/tests\.count="6"/)
    expect(formatter_output).to match(/tests\.skipped="1"/)
    expect(formatter_output).to match(/tests\.failures="3"/)
    expect(formatter_output).to match(/tests\.errors="0"/)
    expect(formatter_output).to match(/tests\.retries="1"/)
  end

  it "reports the slowest spec file", :aggregate_failures do
    execute_example_spec

    expect(formatter_output).to match(/tests\.slow_files="1"/)
    expect(formatter_output).to match(%r{tests\.slowest_file="\./spec/slow_spec\.rb"})
    expect(formatter_output[/tests\.slowest_file_ms="(\d+)"/, 1].to_i).to be >= 300
  end

  it "writes the results on a single line" do
    execute_example_spec

    expect(formatter_output.lines.size).to eq(1)
    expect(formatter_output).to start_with('tests.count="6" ')
    expect(formatter_output).not_to include("tests.worker")
    expect(formatter_output).not_to include("tests.node")
  end

  it "includes the parallel worker number" do
    example_env["TEST_ENV_NUMBER"] = "3"
    execute_example_spec

    expect(formatter_output).to start_with('tests.worker="3" tests.count="6" ')
  end

  it "includes the CI node before the worker number" do
    example_env["CIRCLE_NODE_INDEX"] = "1"
    example_env["TEST_ENV_NUMBER"] = "3"
    execute_example_spec

    expect(formatter_output).to start_with('tests.node="1" tests.worker="3" tests.count="6" ')
  end

  it "treats an empty worker number as the first worker, like parallel_tests" do
    example_env["TEST_ENV_NUMBER"] = ""
    execute_example_spec

    expect(formatter_output).to start_with('tests.worker="1" ')
  end

  it "counts no slow files when all are under the threshold" do
    example_env["RSPEC_LOGFMT_SLOW_FILE_THRESHOLD_MS"] = "60000"
    execute_example_spec

    expect(formatter_output).to match(/tests\.slow_files="0"/)
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

  it "collates one line per worker, keeping the slowest file with its duration" do
    collated = described_class.collate <<~TXT
      tests.worker="1" tests.count="2" tests.slow_files="1" tests.slowest_file_ms="900" tests.slowest_file="./spec/a_spec.rb"
      tests.worker="2" tests.count="3" tests.slow_files="2" tests.slowest_file_ms="1500" tests.slowest_file="./spec/b_spec.rb"
      tests.worker="3" tests.count="1" tests.slow_files="0" tests.slowest_file_ms="100" tests.slowest_file="./spec/c_spec.rb"
    TXT

    expect(collated).to eq <<~TXT.chomp
      tests.count="6"
      tests.slow_files="3"
      tests.slowest_file_ms="1500"
      tests.slowest_file="./spec/b_spec.rb"
    TXT
  end

  it "keeps the CI node when collating" do
    collated = described_class.collate <<~TXT
      tests.node="1" tests.worker="0" tests.count="2"
      tests.node="1" tests.worker="1" tests.count="3"
    TXT

    expect(collated).to eq <<~TXT.chomp
      tests.node="1"
      tests.count="5"
    TXT
  end

  it "collates workers that ran no example groups" do
    collated = described_class.collate <<~TXT
      tests.worker="1" tests.count="0" tests.failures="0"
      tests.worker="2" tests.count="4" tests.failures="1" tests.slowest_file_ms="700" tests.slowest_file="./spec/a_spec.rb"
    TXT

    expect(collated).to eq <<~TXT.chomp
      tests.count="4"
      tests.failures="1"
      tests.slowest_file_ms="700"
      tests.slowest_file="./spec/a_spec.rb"
    TXT
  end
end
