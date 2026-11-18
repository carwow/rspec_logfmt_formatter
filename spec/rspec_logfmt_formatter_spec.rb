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
  let(:test_env_number) { nil }
  let(:circle_node_index) { nil }
  let(:example_env) do
    {
      "TEST_ENV_NUMBER" => test_env_number,
      "CIRCLE_NODE_INDEX" => circle_node_index
    }
  end

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

  describe "formatter output" do
    context "when not running in parallel" do
      before { execute_example_spec }

      it "writes one field per line, slowest file first, under the bare tests prefix" do
        expect(formatter_output).to match(
          /\A
          tests\.slowest_file="\.\/spec\/slow_spec\.rb"\n
          tests\.slowest_file_ms="\d+"\n
          tests\.count="7"\n
          tests\.skipped="1"\n
          tests\.failures="3"\n
          tests\.errors="0"\n
          tests\.retries="1"\n
          \z/x
        )
      end

      it "reports the duration of the slowest spec file in milliseconds" do
        slowest_ms = formatter_output[/tests\.slowest_file_ms="(\d+)"/, 1].to_i

        # slow_spec.rb has two top-level groups, each sleeping 300ms in a before(:all),
        # so this only passes if their times are summed per file
        expect(slowest_ms).to be >= 600
      end
    end

    context "when running under a parallel worker" do
      let(:test_env_number) { "3" }

      it "prefixes every field with the worker number" do
        execute_example_spec

        expect(formatter_output.lines).to all(start_with("tests.3."))
        expect(formatter_output).to include(%(tests.3.slowest_file="./spec/slow_spec.rb"))
        expect(formatter_output).to include(%(tests.3.count="7"))
      end
    end

    context "when running as the first parallel_tests worker, which leaves TEST_ENV_NUMBER empty" do
      let(:test_env_number) { "" }

      it "treats it as worker 1" do
        execute_example_spec

        expect(formatter_output.lines).to all(start_with("tests.1."))
      end

      it "produces output that still collates" do
        execute_example_spec

        expect(described_class.collate(formatter_output)).to include(%(tests.count="7"))
      end
    end

    context "when running under a parallel worker on a CI node" do
      let(:test_env_number) { "3" }
      let(:circle_node_index) { "1" }

      it "prefixes every field with the node and worker number" do
        execute_example_spec

        expect(formatter_output.lines).to all(start_with("tests.1-3."))
        expect(formatter_output).to include(%(tests.1-3.slowest_file="./spec/slow_spec.rb"))
        expect(formatter_output).to include(%(tests.1-3.count="7"))
      end
    end

    context "when on a CI node without a parallel worker" do
      let(:circle_node_index) { "1" }

      it "ignores the node and uses the bare tests prefix" do
        execute_example_spec

        expect(formatter_output.lines).to all(match(/\Atests\.[a-z_]+="/))
      end
    end

    it "produces output that collates back to the same totals and slowest file" do
      execute_example_spec

      collated = described_class.collate(formatter_output)

      expect(collated).to match(
        /\A
        tests\.count="7"\n
        tests\.errors="0"\n
        tests\.failures="3"\n
        tests\.retries="1"\n
        tests\.skipped="1"\n
        tests\.slowest_file="\.\/spec\/slow_spec\.rb"\n
        tests\.slowest_file_ms="\d+"
        \z/x
      )
    end
  end

  describe ".collate" do
    it "sums the counters across workers, omitting the slowest fields when none were reported" do
      collated = described_class.collate <<~TXT
        tests.1.count="2"
        tests.1.skipped="1"
        tests.1.errors="0"
        tests.1.failures="1"
        tests.1.retries="1"
        tests.2.count="3"
        tests.2.skipped="0"
        tests.2.errors="1"
        tests.2.failures="2"
        tests.2.retries="0"
      TXT

      expect(collated).to eq <<~TXT.chomp
        tests.count="5"
        tests.errors="1"
        tests.failures="3"
        tests.retries="1"
        tests.skipped="1"
      TXT
    end

    it "keeps the slowest file across workers along with its own duration" do
      collated = described_class.collate <<~TXT
        tests.1.slowest_file="./spec/a_spec.rb"
        tests.1.slowest_file_ms="900"
        tests.1.count="2"
        tests.2.slowest_file="./spec/b_spec.rb"
        tests.2.slowest_file_ms="1500"
        tests.2.count="3"
        tests.3.slowest_file="./spec/c_spec.rb"
        tests.3.slowest_file_ms="100"
        tests.3.count="1"
      TXT

      expect(collated).to eq <<~TXT.chomp
        tests.count="6"
        tests.errors="0"
        tests.failures="0"
        tests.retries="0"
        tests.skipped="0"
        tests.slowest_file="./spec/b_spec.rb"
        tests.slowest_file_ms="1500"
      TXT
    end

    it "pairs each duration with its own worker's file when workers' output is interleaved" do
      collated = described_class.collate <<~TXT
        tests.1.slowest_file="./spec/a_spec.rb"
        tests.2.slowest_file="./spec/b_spec.rb"
        tests.2.slowest_file_ms="400"
        tests.1.slowest_file_ms="800"
      TXT

      expect(collated).to include(%(tests.slowest_file="./spec/a_spec.rb"\ntests.slowest_file_ms="800"))
    end

    it "pairs a worker's file and duration whichever order they appear in" do
      collated = described_class.collate <<~TXT
        tests.1.slowest_file_ms="800"
        tests.1.slowest_file="./spec/a_spec.rb"
        tests.2.slowest_file="./spec/b_spec.rb"
        tests.2.slowest_file_ms="400"
      TXT

      expect(collated).to include(%(tests.slowest_file="./spec/a_spec.rb"\ntests.slowest_file_ms="800"))
    end

    it "keeps the first file seen when durations tie" do
      collated = described_class.collate <<~TXT
        tests.1.slowest_file="./spec/a_spec.rb"
        tests.1.slowest_file_ms="500"
        tests.2.slowest_file="./spec/b_spec.rb"
        tests.2.slowest_file_ms="500"
      TXT

      expect(collated).to include(%(tests.slowest_file="./spec/a_spec.rb"))
    end

    it "collates workers prefixed with a CI node" do
      collated = described_class.collate <<~TXT
        tests.0-1.slowest_file="./spec/a_spec.rb"
        tests.0-1.slowest_file_ms="700"
        tests.0-1.count="2"
        tests.1-1.slowest_file="./spec/b_spec.rb"
        tests.1-1.slowest_file_ms="300"
        tests.1-1.count="3"
      TXT

      expect(collated).to eq <<~TXT.chomp
        tests.count="5"
        tests.errors="0"
        tests.failures="0"
        tests.retries="0"
        tests.skipped="0"
        tests.slowest_file="./spec/a_spec.rb"
        tests.slowest_file_ms="700"
      TXT
    end

    it "collates output from a run that was not parallelised" do
      collated = described_class.collate <<~TXT
        tests.slowest_file="./spec/a_spec.rb"
        tests.slowest_file_ms="250"
        tests.count="4"
        tests.failures="1"
      TXT

      expect(collated).to eq <<~TXT.chomp
        tests.count="4"
        tests.errors="0"
        tests.failures="1"
        tests.retries="0"
        tests.skipped="0"
        tests.slowest_file="./spec/a_spec.rb"
        tests.slowest_file_ms="250"
      TXT
    end

    it "collates workers that ran no example groups and so report no slowest file" do
      collated = described_class.collate <<~TXT
        tests.1.count="0"
        tests.1.failures="0"
        tests.2.slowest_file="./spec/a_spec.rb"
        tests.2.slowest_file_ms="700"
        tests.2.count="4"
        tests.2.failures="1"
      TXT

      expect(collated).to eq <<~TXT.chomp
        tests.count="4"
        tests.errors="0"
        tests.failures="1"
        tests.retries="0"
        tests.skipped="0"
        tests.slowest_file="./spec/a_spec.rb"
        tests.slowest_file_ms="700"
      TXT
    end

    it "ignores a duration with no file reported for that worker" do
      collated = described_class.collate <<~TXT
        tests.1.slowest_file_ms="9999"
        tests.2.slowest_file="./spec/a_spec.rb"
        tests.2.slowest_file_ms="100"
      TXT

      expect(collated).to include(%(tests.slowest_file="./spec/a_spec.rb"\ntests.slowest_file_ms="100"))
    end

    it "returns zeroed counters and no slowest fields for empty input" do
      collated = described_class.collate("")

      expect(collated).to eq <<~TXT.chomp
        tests.count="0"
        tests.errors="0"
        tests.failures="0"
        tests.retries="0"
        tests.skipped="0"
      TXT
    end
  end
end
