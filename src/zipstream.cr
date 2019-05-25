require "zip"
require "http/server"
require "mime"
require "option_parser"

require "./zipstream/*"

module Zipstream
  VERSION = "0.1.0"

  def self.config
    Config::INSTANCE
  end

  def self.run
    CLI.new

    server = HTTP::Server.new do |context|
      context.response.content_type = MIME.from_extension(".zip")
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.output}\""

      reader, writer = IO.pipe

      if File.directory?(config.path)
        fork { Helpers.zip_directory!(config.path, writer) }
      else
        fork { Helpers.zip_file!(config.path, writer) }
      end

      writer.close

      while line = reader.gets(chomp: false)
        context.response.puts line
      end

      reader.close
    end

    puts "Serving `#{config.path}` as `#{config.output}`"

    address = server.bind_tcp(config.host, config.port)

    puts <<-EOF
      To download the file please use one of the commands below:

      wget --content-disposition http://#{address}
      curl -OJ http://#{address}

      Or just open in browser: http://#{address}
      EOF

    server.listen
  end
end

Zipstream.run
