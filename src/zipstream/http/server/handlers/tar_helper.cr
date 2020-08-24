module Zipstream
  module TarHelper
    def tar_directory!(path : String, io)
      Crystar::Writer.open(io) do |tar|
        Dir[File.join(path, "**/*")].each do |entry|
          next unless File.readable?(entry)

          relative_path = [config.prefix, entry.sub(path, "").lstrip("/")].compact.join("/")

          permissions = File.info(entry).permissions.value.to_i64

          if File.directory?(entry)
            header = Crystar::Header.new(
              name: "#{relative_path}/",
              mode: permissions,
              mod_time: File.info(entry).modification_time,
              size: 0_i64
            )

            tar.write_header(header)
            nil
          else
            header = Crystar::Header.new(
              name: relative_path,
              mode: permissions,
              mod_time: File.info(entry).modification_time,
              size: File.info(entry).size.to_i64
            )

            tar.write_header(header)
            tar.write(File.read(entry).to_slice)
          end
        end
      end
    end

    def tar_file!(path : String, io)
      permissions = File.info(path).permissions.value.to_i64

      Crystar::Writer.open(io) do |tar|
        header = Crystar::Header.new(
          name: File.basename(path),
          mode: permissions,
          mod_time: File.info(path).modification_time,
          size: File.info(path).size.to_i64
        )

        tar.write_header(header)
        tar.write(File.read(path).to_slice)
      end
    end
  end
end
