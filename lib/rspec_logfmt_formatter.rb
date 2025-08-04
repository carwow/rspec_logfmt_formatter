require "rspec/core"
require "rspec/core/formatters/base_formatter"

class RspecLogfmtFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def self.collate(input)
    collated = {}

    input.scan(/(tests\.\w+)="(\d+)"/) do |key, value|
      collated[key] = collated[key].to_i + value.to_i
    end

    collated.map { |key, value| "#{key}=\"#{value}\"" }.join("\n")
  end

  def initialize(...)
    super
    @retries = []
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
      %(tests.count="#{@summary.example_count}"),
      %(tests.skipped="#{@summary.pending_count}"),
      %(tests.failures="#{@summary.failure_count}"),
      %(tests.errors="#{@summary.errors_outside_of_examples_count}"),
      %(tests.retries="#{@retries.count}")
    ].join("\n")
  end
end
