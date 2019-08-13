module Zipstream
  class CLI
    property config

    def initialize
      @config = Config.config

      parse
    end

    private def parse
      optparse = OptionParser.new do |parser|
        parser.banner = <<-EOF
          NAME
              zipstream - is a command line tool that allows you to easily share files and directories as ZIP archive over a network

          VERSION
              #{Zipstream::VERSION}

          SYNOPSIS
              zipstream PATH [options]

          If PATH is not specified it point to current directory

          OPTIONS
          EOF

        parser.on("-h", "--help", "Show this message") do
          puts parser
          exit
        end

        parser.on("-H HOST", "--host=HOST", "Specifies the host (default: #{config.host})") do |name|
          config.host = name
        end

        parser.on("-p PORT", "--port=PORT", "Specifies the port (default: #{config.port})") do |name|
          unless name.chars.all?(&.number?)
            puts "ERROR: `#{name}` is not valid port number"
            exit
          end

          config.port = name.to_i
        end

        parser.on("-o FILENAME", "--output=FILENAME", "Specifies the output file name (default: #{config.output})") do |name|
          config.output = name
        end

        parser.invalid_option do |flag|
          puts "ERROR: #{flag} is not a valid option."
          puts parser
          exit
        end
      end

      optparse.parse!

      config.path = File.expand_path(ARGV.pop? || config.path, Dir.current)

      unless File.exists?(config.path)
        puts "Path `#{config.path}` does not exist"
        exit
      end
    end
  end
end
