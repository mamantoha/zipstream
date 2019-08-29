module Zipstream
  class ZipHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = MIME.from_extension(".zip")
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      if File.directory?(config.path)
        fork { zip_directory!(config.path, writer) }
      else
        fork { zip_file!(config.path, writer) }
      end

      writer.close

      while line = reader.gets(chomp: false)
        context.response.puts line
      end

      reader.close

      call_next(context)
    end

    private def zip_directory!(path : String, io : IO)
      Zip::Writer.open(io) do |zip|
        Dir[File.join(path, "**/*")].each do |entry|
          next unless File.readable?(entry)

          relative_path = entry.sub(path, "")

          if File.directory?(entry)
            zip.add_dir(relative_path)
          else
            zip.add(relative_path, File.open(entry))
          end
        end
      end
    end

    private def zip_file!(file : String, io : IO)
      Zip::Writer.open(io) do |zip|
        zip.add("/#{File.basename(file)}", File.open(file))
      end
    end
  end
end
