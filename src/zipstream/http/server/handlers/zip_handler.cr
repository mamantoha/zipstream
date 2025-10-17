require "../../../helpers/zip_helper"

module Zipstream
  class ZipHandler
    include HTTP::Handler
    include Zipstream::ZipHelper

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = "application/zip"
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      spawn do
        begin
          while line = reader.gets(chomp: false)
            context.response.puts(line)
          end
        rescue ex : HTTP::Server::ClientError
          # Client disconnected, ignore the error
        end

        reader.close
      end

      begin
        if File.directory?(config.path)
          zip_directory!(config.path, writer)
        else
          zip_file!(config.path, writer)
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
