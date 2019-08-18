module Zipstream
  class Config
    INSTANCE = Config.new

    property host
    property port
    property output
    property format
    property path
    property url_path
    property user : String? = nil
    property password : String? = nil

    def initialize
      @host = "127.0.0.1"
      @port = 8090
      @format = "zip"
      @output = "download"
      @path = Dir.current
      @url_path = ""
    end

    def self.config
      Config::INSTANCE
    end

    def filename
      [@output, @format].join(".")
    end

    def basic_auth?
      @user && @password
    end
  end
end
