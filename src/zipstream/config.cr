module Zipstream
  class Config
    INSTANCE = Config.new

    property host
    property port
    property log : Bool = false
    property web : Bool = false
    property output
    property format
    property path
    property url_path
    property env
    property user : String? = nil
    property password : String? = nil

    def initialize
      @host = "0.0.0.0"
      @port = 8090
      @format = "zip"
      @output = "download"
      @path = Dir.current
      @url_path = ""
      @env = "development"
    end

    def filename
      [@output, @format].join(".")
    end

    def basic_auth?
      @user && @password
    end
  end
end
