module Zipstream
  class SymlinkStaticFileHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      if config.no_symlinks? && contains_symlink_in_parent_directory?(config.path, context.request.path.chomp('/'))
        context.response.respond_with_status(:not_found)

        return
      end

      call_next(context)
    end

    # Check if any parent directory within the base path contains a symlink
    private def contains_symlink_in_parent_directory?(base_path, relative_path)
      path = File.join(base_path, relative_path)

      loop do
        return true if File.symlink?(path)

        parent_directory = File.dirname(path)

        break if parent_directory == path || parent_directory == base_path

        path = parent_directory
      end

      false
    end
  end
end
