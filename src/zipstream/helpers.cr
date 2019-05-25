module Zipstream
  module Helpers
    # ```
    # File.open("file.zip", "a") do |zip_file|
    #   zip_directory!("/home/user", zip_file)
    # end
    # ```
    def self.zip_directory!(path : String, io : IO)
      Zip::Writer.open(io) do |zip|
        Dir[File.join(path, "**/*")].each do |file|
          relative_path = file.sub(Regex.escape(path), "")

          if File.directory?(file)
            zip.add_dir(relative_path)
          else
            zip.add(relative_path, File.open(file))
          end
        end
      end
    end

    def self.zip_file!(file : String, io : IO)
      Zip::Writer.open(io) do |zip|
        zip.add("/#{File.basename(file)}", File.open(file))
      end
    end
  end
end
