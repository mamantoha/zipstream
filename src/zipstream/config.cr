module Zipstream
  class Config
    INSTANCE = Config.new

    property host
    property port
    property log : Bool = false
    property web : Bool = false
    property qr : Bool = false
    property output
    property format
    property path
    property url_path
    property env
    property user : String? = nil
    property password : String? = nil
    property prefix : String? = nil
    property junk : Bool = false
    property hidden : Bool = false
    property no_banner : Bool = false

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
      [output, format].join(".")
    end

    def basic_auth?
      user && password
    end

    def self.release_date
      {{ `date -R`.stringify.chomp }}
    end

    def remote_url : String
      address = Socket::IPAddress.new(host, port)

      String.build do |str|
        str << "http://"
        str << "#{user}:#{password}@" if basic_auth?
        str << address
        str << '/'
        str << url_path
      end
    end
  end
end
