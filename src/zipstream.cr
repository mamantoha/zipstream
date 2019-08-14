require "zip"
require "http/server"
require "mime"
require "option_parser"
require "crystar"

require "./zipstream/**"

module Zipstream
  def self.config
    Config::INSTANCE
  end

  def self.run
    CLI.new

    handler =
      case config.format
      when "zip"
        ZipHandler.new(config)
      when "tar"
        TarHandler.new(config)
      else
        ZipHandler.new(config)
      end

    server = HTTP::Server.new([
      HTTP::LogHandler.new,
      handler,
    ]) do |context|
    end

    address = server.bind_tcp(config.host, config.port)

    puts "Serving `#{config.path}` as `#{config.filename}`"
    puts

    if config.format == "zip"
      puts <<-EOF
        To download the file please use one of the commands below:

        wget --content-disposition http://#{address}
        curl -OJ http://#{address}

        Or just open in browser: http://#{address}
        EOF
    elsif config.format == "tar"
      puts <<-EOF
        To download the file please use one of the commands below:

        wget --content-disposition http://#{address}
        curl -OJ http://#{address}

        Or place all files into current folder:

        wget -O- http://#{address} | tar -xvf -
        curl http://#{address} | tar -xvf -

        Or just open in browser: http://#{address}
        EOF
    end

    server.listen
  end
end

Zipstream.run
