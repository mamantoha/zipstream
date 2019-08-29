module Zipstream
  class TarHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = MIME.from_extension(".tar")
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      if File.directory?(config.path)
        fork { tar_directory!(config.path, writer) }
      else
        fork { tar_file!(config.path, writer) }
      end

      writer.close

      while line = reader.gets(chomp: false)
        context.response.puts line
      end

      reader.close

      call_next(context)
    end

    private def tar_directory!(path : String, io : IO)
      Crystar::Writer.open(io) do |tar|
        Dir[File.join(path, "**/*")].each do |entry|
          next unless File.readable?(entry)

          relative_path = entry.sub(path, "").lstrip("/")
          permissions = File.info(entry).permissions.value.to_i64

          if File.directory?(entry)
            header = Crystar::Header.new(
              name: "#{relative_path}/",
              mode: permissions,
              size: 0_i64
            )

            tar.write_header(header)
            nil
          else
            header = Crystar::Header.new(
              name: relative_path,
              mode: permissions,
              size: File.info(entry).size.to_i64
            )

            tar.write_header(header)
            tar.write(File.read(entry).to_slice)
          end
        end
      end
    end

    private def tar_file!(file : String, io : IO)
      permissions = File.info(file).permissions.value.to_i64

      Crystar::Writer.open(io) do |tar|
        header = Crystar::Header.new(
          name: File.basename(file),
          mode: permissions,
          size: File.info(file).size.to_i64
        )

        tar.write_header(header)
        tar.write(File.read(file).to_slice)
      end
    end
  end
end
