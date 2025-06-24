require "./archive_helper"

module Zipstream
  class ZipHandler
    include HTTP::Handler
    include Zipstream::ArchiveHelper

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = "application/zip"
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      spawn same_thread: true do
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

    private def zip_directory!(path : String, io : IO)
      base_path = Path[path].to_posix

      Zip64::Writer.open(io) do |zip|
        # Path separator in patterns needs to be always /
        pattern = base_path.join("**/*")

        Dir.glob(pattern, match: file_match_options).each do |entry|
          next unless File::Info.readable?(entry)
          next if config.no_symlinks? && File.symlink?(entry)

          entry_path = Path[entry].to_posix

          relative_path = relative_path(base_path, entry_path)

          if File.directory?(entry)
            zip.add_dir(relative_path)
          else
            zip.add(relative_path, File.open(entry))
          end
        end
      end
    end

    private def zip_file!(file : String, io : IO)
      Zip64::Writer.open(io) do |zip|
        zip.add("/#{File.basename(file)}", File.read(file))
      end
    end
  end
end
