module Zipstream
  class TarHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = "application/x-tar"
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      spawn same_thread: true do
        while line = reader.gets(chomp: false)
          context.response.puts line
        end

        reader.close
      end

      if File.directory?(config.path)
        tar_directory!(config.path, writer)
      else
        tar_file!(config.path, writer)
      end

      writer.close

      Fiber.yield

      call_next(context)
    end

    private def tar_directory!(path : String, io : IO)
      Zipstream::Helper.tar_directory!(path, io)
    end

    private def tar_file!(path : String, io : IO)
      Zipstream::Helper.tar_file!(path, io)
    end
  end
end
