require "../spec_helper"

describe Zipstream::Config do
  config = Zipstream::Config.new

  context "host" do
    it "should has host as local IP address" do
      config.host.should match(/\d+\.\d+\.\d+\.\d+/)
    end
  end
end
