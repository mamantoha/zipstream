module Zipstream
  class TgzHandler
    include HTTP::Handler

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

      if File.directory?(config.path)
        tgz_directory!(config.path, writer)
      else
        tgz_file!(config.path, writer)
      end

      writer.close

      Fiber.yield

      call_next(context)
    end

    private def tgz_directory!(path : String, io : IO)
      Compress::Gzip::Writer.open(io) do |gzip|
        Zipstream::Helper.tar_directory!(path, gzip)
      end
    end

    private def tgz_file!(path : String, io : IO)
      Compress::Gzip::Writer.open(io) do |gzip|
        Zipstream::Helper.tar_file!(path, gzip)
      end
    end
  end
end
