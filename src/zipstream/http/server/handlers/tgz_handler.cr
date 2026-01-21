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

      WaitGroup.wait do |wg|
        reader, writer = IO.pipe

        wg.spawn do
          begin
            while line = reader.gets(chomp: false)
              context.response.print line
            end
          rescue HTTP::Server::ClientError
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
        rescue IO::Error
          # Client disconnected, ignore the error
        end

        writer.close
      end

      call_next(context)
    end
  end
end
