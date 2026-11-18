require "spec_helper"

describe "SlowSpecs" do
  before(:all) { sleep 0.3 }

  it "succeeds slowly" do
    expect(1).to eq(1)
  end
end

describe "MoreSlowSpecs" do
  before(:all) { sleep 0.3 }

  it "succeeds slowly too" do
    expect(1).to eq(1)
  end
end
