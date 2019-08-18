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

    handlers = [] of HTTP::Handler

    handlers << BeforeHandler.new(config)

    if config.basic_auth?
      handlers << BasicAuthHandler.new(config.user.not_nil!, config.password.not_nil!)
    end

    handlers << archive_handler

    server = HTTP::Server.new(handlers) do |context|
    end

    address = server.bind_tcp(config.host, config.port)

    puts "Serving `#{config.path}` as `#{config.filename}`"
    puts

    puts message(address, config)

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

  private def self.message(address, config)
    wget_command = [] of String
    wget_command << "wget"
    wget_command << "--content-disposition"

    if config.basic_auth?
      wget_command << "--user #{config.user}"
      wget_command << "--password #{config.password}"
    end

    wget_command << "http://#{address}/#{config.url_path}"

    curl_command = [] of String
    curl_command << "curl"

    curl_command << "-OJ"

    if config.basic_auth?
      curl_command << "--user #{config.user}:#{config.password}"
    end

    curl_command << "http://#{address}/#{config.url_path}"

    message = String::Builder.new

    message.puts "To download the file please use one of the commands below:"
    message.puts ""

    message.puts wget_command.reject(&.empty?).join(" ")
    message.puts curl_command.reject(&.empty?).join(" ")

    if config.format == "tar"
      message.puts ""
      message.puts "Or place all files into current folder:"
      message.puts ""

      message.print wget_command.reject(&.empty?).join(" ")
      message.puts " | tar -xvf -"

      message.print curl_command.reject(&.empty?).join(" ")
      message.puts " | tar -xvf -"
    end

    message.puts ""
    message.puts "Or just open in browser: http://#{address}/#{config.url_path}"

    message.to_s
  end
end

Zipstream.run
