module Zipstream
  class ZipHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = "application/zip"
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      spawn same_thread: true do
        while line = reader.gets(chomp: false)
          context.response.puts(line)
        end

        reader.close
      end

      if File.directory?(config.path)
        zip_directory!(config.path, writer)
      else
        zip_file!(config.path, writer)
      end

      writer.close

      Fiber.yield

      call_next(context)
    end

    private def zip_directory!(path : String, io : IO)
      ZipTricks::Streamer.archive(io) do |zip|
        Dir[File.join(path, "**/*")].each do |entry|
          next unless File.readable?(entry)

          relative_path = [config.prefix, entry.sub(path, "").lstrip("/")].compact.join("/")

          if File.directory?(entry)
            zip.add_stored("#{relative_path}/") { }
          else
            zip.add_deflated(relative_path) do |sink|
              sink << File.read(entry)
            end
          end
        end
      end
    end

    private def zip_file!(file : String, io : IO)
      ZipTricks::Streamer.archive(io) do |zip|
        zip.add_deflated("/#{File.basename(file)}") do |sink|
          sink << File.read(file)
        end
      end
    end
  end
end
