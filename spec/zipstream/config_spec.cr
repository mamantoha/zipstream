require "../spec_helper"

describe Zipstream::Config do
  config = Zipstream::Config.new

  context "host" do
    it "should has host" do
      config.host.should eq("")
    end
  end
end
