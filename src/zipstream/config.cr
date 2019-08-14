module Zipstream
  class Config
    INSTANCE = Config.new

    property host
    property port
    property output
    property format
    property path

    def initialize
      @host = "127.0.0.1"
      @port = 8090
      @format = "zip"
      @output = "download"
      @path = Dir.current
    end

    def self.config
      Config::INSTANCE
    end

    def filename
      [@output, @format].join(".")
    end
  end
end
