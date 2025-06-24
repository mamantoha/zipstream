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
      Zip64::Writer.open(io) do |zip|
        file_match_options = config.hidden? ? File::MatchOptions::All : File::MatchOptions::NativeHidden | File::MatchOptions::OSHidden

        # Path separator in patterns needs to be always /
        pattern = Path[path].to_posix.join("**/*")

        Dir.glob(pattern, match: file_match_options).each do |entry|
          next unless File::Info.readable?(entry)
          next if config.no_symlinks? && File.symlink?(entry)

          relative_path = [
            config.prefix,
            entry.sub(path, "").lstrip(Path::SEPARATORS[0]),
          ].compact.join(Path::SEPARATORS[0])

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
