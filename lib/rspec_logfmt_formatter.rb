# frozen_string_literal: true

require 'time'

require 'rspec/core'
require 'rspec/core/formatters/base_formatter'

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

  def error_count
    if @summary_notification.respond_to?(:errors_outside_of_examples_count)
      @summary_notification.errors_outside_of_examples_count
    else
      0
    end
  end

  # rubocop:disable Metrics/AbcSize
  def fmt_dump
    output << %( tests.name="rspec#{ENV['TEST_ENV_NUMBER']}")
    output << %( tests.count="#{example_count}")
    output << %( tests.skipped="#{pending_count}")
    output << %( tests.failures="#{failure_count}")
    output << %( tests.errors="#{error_count}")
    output << %( tests.duration_seconds="#{format('%.6f', duration)}")
    output << %( tests.retries.count="#{retries.size}")
  end
  # rubocop:enable Metrics/AbcSize
end
