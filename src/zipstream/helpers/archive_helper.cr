module Zipstream
  module ArchiveHelper
    extend self

    def file_match_options : File::MatchOptions
      if config.hidden?
        File::MatchOptions::All
      else
        File::MatchOptions::NativeHidden | File::MatchOptions::OSHidden
      end
    end

    def relative_path(base_path : Path, entry_path : Path) : String
      [
        config.prefix,
        entry_path.to_s.sub(base_path.to_s, "").lstrip('/'),
      ].compact.join('/')
    end
  end
end
