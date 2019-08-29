module Zipstream
  class TgzHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      context.response.content_type = MIME.from_extension(".tgz")
      context.response.headers["Content-Disposition"] = "attachment; filename=\"#{config.filename}\""

      reader, writer = IO.pipe

      if File.directory?(config.path)
        fork { tar_directory!(config.path, writer) }
      else
        fork { tar_file!(config.path, writer) }
      end

      writer.close

      while line = reader.gets(chomp: false)
        context.response.print line
      end

      reader.close

      call_next(context)
    end

    private def tar_directory!(path : String, io : IO)
      Gzip::Writer.open(io) do |gzip|
        Crystar::Writer.open(gzip) do |tar|
          Dir[File.join(path, "**/*")].each do |entry|
            next unless File.readable?(entry)

            relative_path = entry.sub(Regex.escape(path), "")
            permissions = File.info(entry).permissions.value.to_i64

            if File.directory?(entry)
              hdr = Crystar::Header.new(
                name: "#{relative_path}/",
                mode: permissions,
                size: 0_i64
              )

              tar.write_header(hdr)
              nil
            else
              hdr = Crystar::Header.new(
                name: relative_path,
                mode: permissions,
                size: File.info(entry).size.to_i64
              )

              tar.write_header(hdr)
              tar.write(File.read(entry).to_slice)
            end
          end
        end
      end
    end

    private def tar_file!(file : String, io : IO)
      permissions = File.info(file).permissions.value.to_i64

      Gzip::Writer.open(io) do |gzip|
        Crystar::Writer.open(gzip) do |tar|
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
end
