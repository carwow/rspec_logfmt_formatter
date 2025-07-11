require 'spec_helper'

describe 'ExampleSpecs' do
  let(:test) { 1 }

  it 'succeeds' do
    expect(test).to be_an(Integer)
  end

  it 'fails' do
    expect(test).to be_a(String)
  end

  it 'raises' do # rubocop:disable RSpec/NoExpectationExample
    raise ArgumentError
  end

  xit 'pending' do # rubocop:disable RSpec/PendingWithoutReason
    pending 'pending'
  end

  it 'retries', :retry_spec do
    expect(test).to be_a(String)
  end
end
