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
  # processes appending to the same file) into one set of totals.
  #
  # Each run's output is one record. Counts are summed, the slowest file is the
  # one with the largest duration across all records.
  def self.collate(input)
    records = parse_records(input)
    collated = {}

    records.each do |record|
      record.each do |key, value|
        case key
        when "tests.slowest_file"
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

  # Splits the input into records, one per formatter run. A new record starts
  # whenever a key repeats within the current one.
  def self.parse_records(input)
    records = [{}]

    input.scan(/^(tests\.[\w.]+)="([^"]*)"/) do |key, value|
      records << {} if records.last.key?(key)
      records.last[key] = value
    end

    records.reject(&:empty?)
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

  def logfmt_dump
    output.puts (summary_lines + slow_file_lines).join("\n")
  end

  def summary_lines
    [
      %(tests.count="#{@summary.example_count}"),
      %(tests.skipped="#{@summary.pending_count}"),
      %(tests.failures="#{@summary.failure_count}"),
      %(tests.errors="#{@summary.errors_outside_of_examples_count}"),
      %(tests.retries="#{@retries.count}")
    ]
  end

  def slow_file_lines
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
