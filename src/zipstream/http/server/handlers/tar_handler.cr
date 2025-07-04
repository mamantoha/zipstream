require "../../../helpers/tar_helper"

module Zipstream
  class TarHandler
    include HTTP::Handler
    include Zipstream::TarHelper

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
  end
end
