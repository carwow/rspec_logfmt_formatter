require "rspec/core"
require "rspec/core/formatters/base_formatter"

class RspecLogfmtFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self,
    :dump_summary,
    :example_group_started,
    :example_group_finished

  SLOW_FILE_THRESHOLD_ENV = "RSPEC_LOGFMT_SLOW_FILE_THRESHOLD_MS"
  DEFAULT_SLOW_FILE_THRESHOLD_MS = 60_000

  # Combines the output of several formatter runs (e.g. parallel test
  # processes appending to the same file) into one set of totals, one field
  # per line.
  #
  # Each line of input is one run's result. Counts are summed, the slowest file
  # is the one with the largest duration across all runs, and the worker number
  # is dropped.
  def self.collate(input)
    collated = {}

    parse_records(input).each do |record|
      record.each do |key, value|
        case key
        when "tests.worker", "tests.slowest_file"
          next
        when "tests.slowest_file_ms"
          if collated[key].nil? || value.to_i > collated[key].to_i
            collated[key] = value
            collated["tests.slowest_file"] = record["tests.slowest_file"] if record.key?("tests.slowest_file")
          end
        else
          collated[key] = (collated[key].to_i + value.to_i).to_s
        end
      end
    end

    collated.map { |key, value| %(#{key}="#{value}") }.join("\n")
  end

  # One record per line of input that has any tests.* fields.
  def self.parse_records(input)
    input.each_line
      .map { |line| line.scan(/(?:\A|\s)(tests\.[\w.]+)="([^"]*)"/).to_h }
      .reject(&:empty?)
  end
  private_class_method :parse_records

  def initialize(...)
    super
    @retries = []
    @file_durations_ms = Hash.new(0)
  end

  def example_group_started(notification)
    return unless notification.group.top_level?

    @group_started_at = RSpec::Core::Time.now
  end

  def example_group_finished(notification)
    group = notification.group
    return unless group.top_level? && @group_started_at

    elapsed_ms = ((RSpec::Core::Time.now - @group_started_at) * 1000).round
    @file_durations_ms[group.metadata[:file_path]] += elapsed_ms
    @group_started_at = nil
  end

  def dump_summary(notification)
    @summary = notification
    logfmt_dump
  end

  # Called by rspec-retry on every formatter that responds to it.
  def retry(example)
    @retries << example
  end

  private

  # One line per run, so parallel workers appending to the same file each
  # write a single, self-contained record.
  def logfmt_dump
    output.puts (worker_fields + summary_fields + slow_file_fields).join(" ")
  end

  # The parallel worker number, from flatware or parallel_tests (which uses
  # "" for its first process).
  def worker_fields
    worker = ENV["TEST_ENV_NUMBER"]
    return [] if worker.nil?

    worker = "1" if worker.empty?
    [%(tests.worker="#{worker}")]
  end

  def summary_fields
    [
      %(tests.count="#{@summary.example_count}"),
      %(tests.skipped="#{@summary.pending_count}"),
      %(tests.failures="#{@summary.failure_count}"),
      %(tests.errors="#{@summary.errors_outside_of_examples_count}"),
      %(tests.retries="#{@retries.count}")
    ]
  end

  def slow_file_fields
    return [] if @file_durations_ms.empty?

    slowest_file, slowest_ms = @file_durations_ms.max_by { |_file, ms| ms }
    slow_files = @file_durations_ms.count { |_file, ms| ms > slow_file_threshold_ms }

    [
      %(tests.slow_files="#{slow_files}"),
      %(tests.slowest_file_ms="#{slowest_ms}"),
      %(tests.slowest_file="#{slowest_file}")
    ]
  end

  def slow_file_threshold_ms
    Integer(ENV.fetch(SLOW_FILE_THRESHOLD_ENV, DEFAULT_SLOW_FILE_THRESHOLD_MS))
  end
end
