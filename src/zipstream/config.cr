module Zipstream
  class Config
    INSTANCE = Config.new

    setter host : String? = nil
    property port
    property? log : Bool = false
    property? web : Bool = false
    property? qr : Bool = false
    property output
    property format
    property path
    property url_path
    property env
    property user : String? = nil
    property password : String? = nil
    property prefix : String? = nil
    property? junk : Bool = false
    property? hidden : Bool = false
    property? no_symlinks : Bool = false
    property? no_banner : Bool = false

    def initialize
      @port = 8090
      @format = "zip"
      @output = "download"
      @path = Dir.current
      @url_path = ""
      @env = "development"
    end

    def host
      @host || local_ip_address.try(&.address) || "0.0.0.0"
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

    def local_ip_address : Socket::IPAddress?
      Socket.ip_address_list.find do |ip_address|
        ip_address.family == Socket::Family::INET && ip_address.private? && !ip_address.address.starts_with?("127")
      end
    end
  end
end
