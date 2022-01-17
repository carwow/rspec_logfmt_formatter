require 'spec_helper'

describe 'ExampleSpecs' do
  let(:test) { 1 }

  it 'succeeds' do
    expect(test).to be_an(Integer)
  end

  it 'fails' do
    expect(test).to be_a(String)
  end

  it 'raises' do
    raise ArgumentError
  end

  xit 'should be pending' do
    pending
  end

  it 'retries', :retry_spec do
    expect(test).to be_a(String)
  end
end
