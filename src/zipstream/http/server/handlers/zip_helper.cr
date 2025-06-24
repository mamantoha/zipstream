module Zipstream
  module ZipHelper
    include Zipstream::ArchiveHelper

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
