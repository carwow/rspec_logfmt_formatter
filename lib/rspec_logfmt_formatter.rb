require "rspec/core"
require "rspec/core/formatters/base_formatter"

class RspecLogfmtFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self,
    :dump_summary,
    :example_group_started,
    :example_group_finished

  COUNTERS = %w[count errors failures retries skipped].freeze
  SLOWEST_FIELDS = %w[slowest_file slowest_file_ms].freeze

  def self.collate(input)
    totals = COUNTERS.to_h { |counter| [counter, 0] }
    pending = Hash.new { |hash, worker| hash[worker] = {} }
    slowest = []

    input.scan(/tests((?:\.[\w-]+)?)\.(\w+)="([^"]+)"/) do |worker, field, value|
      if totals.key?(field)
        totals[field] += value.to_i
      elsif SLOWEST_FIELDS.include?(field)
        # Pair a worker's file and duration in whichever order they arrive
        pair = pending[worker]
        pair[field] = value
        next unless pair.size == 2

        pending.delete(worker)
        slowest << [pair["slowest_file"], pair["slowest_file_ms"].to_i]
      end
    end

    file, ms = slowest.max_by(&:last) # first wins on ties
    fields = totals.map { |counter, total| %(tests.#{counter}="#{total}") }
    fields.push(%(tests.slowest_file="#{file}"), %(tests.slowest_file_ms="#{ms}")) if file
    fields.join("\n")
  end

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

  def retry(example)
    @retries << example
  end

  private

  def logfmt_dump
    output.puts [
      slow_file_fields,
      %(#{prefix}.count="#{@summary.example_count}"),
      %(#{prefix}.skipped="#{@summary.pending_count}"),
      %(#{prefix}.failures="#{@summary.failure_count}"),
      %(#{prefix}.errors="#{@summary.errors_outside_of_examples_count}"),
      %(#{prefix}.retries="#{@retries.count}")
    ].join("\n")
  end

  def slow_file_fields
    return [] if @file_durations_ms.empty?

    slowest_file, slowest_ms = @file_durations_ms.max_by { |_file, duration| duration }

    [
      %(#{prefix}.slowest_file="#{slowest_file}"),
      %(#{prefix}.slowest_file_ms="#{slowest_ms}")
    ]
  end

  def prefix
    @prefix ||= begin
      worker = ENV["TEST_ENV_NUMBER"]
      if worker
        # parallel_tests leaves TEST_ENV_NUMBER empty for the first worker
        worker = "1" if worker.empty?
        node = ENV["CIRCLE_NODE_INDEX"]
        node ? "tests.#{node}-#{worker}" : "tests.#{worker}"
      else
        "tests"
      end
    end
  end
end
