require "./tar_helper"

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

      spawn same_thread: true do
        while line = reader.gets(chomp: false)
          context.response.print line
        end

        reader.close
      end

      Compress::Gzip::Writer.open(writer) do |gzip|
        if File.directory?(config.path)
          tar_directory!(config.path, gzip)
        else
          tar_file!(config.path, gzip)
        end
      end

      writer.close

      Fiber.yield

      call_next(context)
    end
  end
end
