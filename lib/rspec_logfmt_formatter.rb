# frozen_string_literal: true

require "time"

require "rspec/core"
require "rspec/core/formatters/base_formatter"


class RspecLogfmtFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self,
    :start,
    :stop,
    :dump_summary

  def start(notification)
    @start_notification = notification
    @started = Time.now
    @retries = []
    super
  end

  def stop(notification)
    @examples_notification = notification
  end

  def dump_summary(notification)
    @summary_notification = notification
    fmt_dump
  end

  def retry(example)
    @retries << example
  end

private

  attr_reader :started, :retries

  def example_count
    @summary_notification.example_count
  end

  def pending_count
    @summary_notification.pending_count
  end

  def failure_count
    @summary_notification.failure_count
  end

  def duration
    @summary_notification.duration
  end

  def examples
    @examples_notification.notifications
  end

  def error_count
    # Introduced in rspec 3.6
    if @summary_notification.respond_to?(:errors_outside_of_examples_count)
      @summary_notification.errors_outside_of_examples_count
    else
      0
    end
  end

  def fmt_dump
    output << %{ rspec.name="rspec#{ENV["TEST_ENV_NUMBER"].to_s}"}
    output << %{ rspec.tests="#{example_count}"}
    output << %{ rspec.skipped="#{pending_count}"}
    output << %{ rspec.failures="#{failure_count}"}
    output << %{ rspec.errors="#{error_count}"}
    output << %{ rspec.time="#{"%.6f" % duration}"}
    output << %{ rspec.timestamp="#{started.iso8601}"}
    output << %{ rspec.retries.count="#{retries.size}"}
    output << %{\n}
  end
end
