module Zipstream
  class Config
    INSTANCE = Config.new

    property host
    property port
    property output
    property path

    def initialize
      @host = "127.0.0.1"
      @port = 8090
      @output = "download.zip"
      @path = Dir.current
    end

    def self.config
      Config::INSTANCE
    end
  end
end
