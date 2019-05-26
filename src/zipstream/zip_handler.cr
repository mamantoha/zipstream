module Zipstream
  class ZipHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      if context.request.path != "/"
        context.response.status = :not_found
        return
      end

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

      call_next(context)
    end
  end
end
