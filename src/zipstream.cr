require "compress/gzip"
require "http/server"
require "mime"
require "option_parser"
require "crystar"
require "zip64"
require "qrcode_terminal"
require "ip_address_list"

require "./zipstream/**"

module Zipstream
  extend self

  def config
    Config::INSTANCE
  end

  def run
    CLI.new

    if config.web?
      run_web
    else
      run_cli
    end
  end

  def run_cli
    handlers = [] of HTTP::Handler

    if config.log?
      handlers << LogHandler.new
    end

    handlers << BeforeHandler.new(config)

    if config.basic_auth?
      handlers << BasicAuthHandler.new(config.user.to_s, config.password.to_s)
    end

    handlers << archive_handler

    server = HTTP::Server.new(handlers) { }

    address = server.bind_tcp(config.host, config.port)

    unless File::Info.readable?(config.path)
      puts "#{config.path} : Permission denied"
      exit
    end

    unless config.no_banner?
      puts banner
      puts
    end

    puts "Serving `#{config.path}` as `#{config.filename}`"
    puts

    puts message(address)

    if config.qr?
      puts "Or scan the QR code to access to download the file on your phone"
      puts QRCodeTerminal.generate(config.remote_url)
    end

    Process.on_terminate { shutdown(server) }

    STDOUT.flush

    server.listen unless config.env == "test"
  end

  private def shutdown(server)
    puts
    puts "See you later, alligator!"
    server.close
    exit
  end

  def run_web
    server = Zipstream::Web::Server.new

    unless config.no_banner?
      puts banner
      puts
    end

    puts "Serving `#{config.path}`"
    puts

    puts "Open in your browser: `#{config.remote_url}`"

    if config.qr?
      puts "Or scan the QR code to access `#{config.remote_url}` on your phone"
      puts QRCodeTerminal.generate(config.remote_url)
    end

    server.run unless config.env == "test"
  end

  def archive_handler
    case config.format
    when "zip"
      ZipHandler.new(config)
    when "tar"
      TarHandler.new(config)
    when "tgz"
      TgzHandler.new(config)
    else
      ZipHandler.new(config)
    end
  end

  private def message(address)
    message = String::Builder.new

    message.puts "To download the file please use one of the commands below:"
    message.puts ""

    message.puts wget_command(address)
    message.puts curl_command(address)

    if ["tar", "tgz"].includes?(config.format)
      message.puts ""
      message.puts "Or place all files into current folder:"
      message.puts ""

      message.print wget_command(address, true)
      message.puts extract_command

      message.print curl_command(address, true)
      message.puts extract_command
    end

    message.puts ""
    message.puts "Or just open in your browser: `#{config.remote_url}`"

    message.to_s
  end

  private def wget_command(address, extract = false)
    wget_command = [] of String
    wget_command << "wget"
    wget_command << "-O-" if extract
    wget_command << "--content-disposition" unless extract

    if config.basic_auth?
      wget_command << "--user #{config.user}"
      wget_command << "--password #{config.password}"
    end

    wget_command << "http://#{address}/#{config.url_path}"

    wget_command.reject(&.empty?).join(" ")
  end

  private def curl_command(address, extract = false)
    curl_command = [] of String
    curl_command << "curl"

    curl_command << "-OJ" unless extract

    if config.basic_auth?
      curl_command << "--user #{config.user}:#{config.password}"
    end

    curl_command << "http://#{address}/#{config.url_path}"

    curl_command.reject(&.empty?).join(" ")
  end

  private def extract_command
    case config.format
    when "tar"
      " | tar -xvf -"
    when "tgz"
      " | tar -xzvf -"
    else
      ""
    end
  end

  private def banner
    # https://jonasjacek.github.io/colors/
    c = {
      red:    "\033[38;5;196m",
      orange: "\033[38;5;202m",
      yellow: "\033[38;5;226m",
      green:  "\033[38;5;082m",
      blue:   "\033[38;5;021m",
      cyan:   "\033[38;5;051m",
      purple: "\033[38;5;129m",
      indigo: "\033[38;5;093m",
      violet: "\033[38;5;163m",
      reset:  "\033[m",
    }

    colors = [
      c[:red],
      c[:orange],
      c[:yellow],
      c[:green],
      c[:blue],
      c[:indigo],
      c[:violet],
      c[:indigo],
      c[:cyan],
      c[:reset],
    ]

    lines = [] of String
    lines << %q{%s     %s_%s      %s     %s_   %s     %s    %s      %s          %s} % colors
    lines << %q{%s    %s(_)%s     %s    %s| |  %s     %s    %s      %s          %s} % colors
    lines << %q{%s ____%s_%s _ __ %s ___%s| |_ %s_ __ %s___ %s __ _ %s_ __ ___  %s} % colors
    lines << %q(%s|_  /%s %s| '_ \%s/ __|%s __|%s '__/%s _ \%s/ _` |%s '_ ` _ \ %s) % colors
    lines << %q{%s / /%s| %s| |_) %s\__ \%s |_%s| | %s|  __/%s (_| |%s | | | | |%s} % colors
    lines << %q{%s/___%s|_%s| .__/%s|___/%s\__|%s_|  %s\___|%s\__,_|%s_| |_| |_|%s} % colors
    lines << %q{%s     %s %s| |   %s     %s    %s     %s    %s      %s          %s} % colors
    lines << %q{%s     %s %s|_|   %s     %s    %s     %s    %s      %s          %s} % colors

    lines.join("\n")
  end
end
