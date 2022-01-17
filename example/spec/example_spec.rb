require 'spec_helper'

describe 'some example specs' do
  it 'succeeds' do
    expect(true).to be(true)
  end

  it 'fails' do
    expect(false).to be(true)
  end

  it 'raises' do
    raise ArgumentError
  end

  xit 'should be pending' do
    pending
  end
end
