require "../../../helpers/tar_helper"

module Zipstream
  class TgzHandler
    include HTTP::Handler
    include Zipstream::TarHelper

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = "application/x-gtar-compressed"
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      spawn do
        begin
          while line = reader.gets(chomp: false)
            context.response.print line
          end
        rescue ex : HTTP::Server::ClientError
          # Client disconnected, ignore the error
        end

        reader.close
      end

      begin
        Compress::Gzip::Writer.open(writer) do |gzip|
          if File.directory?(config.path)
            tar_directory!(config.path, gzip)
          else
            tar_file!(config.path, gzip)
          end
        end
      rescue ex : IO::Error
        # Client disconnected, ignore the error
      end

      writer.close

      Fiber.yield

      call_next(context)
    end
  end
end
