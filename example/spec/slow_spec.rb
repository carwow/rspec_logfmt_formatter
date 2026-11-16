require "spec_helper"

describe "SlowSpecs" do
  before(:all) { sleep 0.3 }

  it "succeeds slowly" do
    expect(1).to eq(1)
  end
end
