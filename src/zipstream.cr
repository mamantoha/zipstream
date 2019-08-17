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

    archive_handler =
      case config.format
      when "zip"
        ZipHandler.new(config)
      when "tar"
        TarHandler.new(config)
      else
        ZipHandler.new(config)
      end

      handlers = [
        # HTTP::LogHandler.new,
        BeforeHandler.new(config),
        archive_handler
      ]

    server = HTTP::Server.new(handlers) do |context|
    end

    address = server.bind_tcp(config.host, config.port)

    puts "Serving `#{config.path}` as `#{config.filename}`"
    puts

    if config.format == "zip"
      puts <<-EOF
        To download the file please use one of the commands below:

        wget --content-disposition http://#{address}/#{config.url_path}
        curl -OJ http://#{address}

        Or just open in browser: http://#{address}
        EOF
    elsif config.format == "tar"
      puts <<-EOF
        To download the file please use one of the commands below:

        wget --content-disposition http://#{address}/#{config.url_path}
        curl -OJ http://#{address}/#{config.url_path}

        Or place all files into current folder:

        wget -O- http://#{address}/#{config.url_path} | tar -xvf -
        curl http://#{address}/#{config.url_path} | tar -xvf -

        Or just open in browser: http://#{address}/#{config.url_path}
        EOF
    end

    shutdown = ->(s : Signal) do
      puts
      puts "See you later, alligator!"
      server.close
      exit
    end

    Signal::INT.trap &shutdown
    Signal::TERM.trap &shutdown

    STDOUT.flush

    server.listen
  end
end

Zipstream.run
