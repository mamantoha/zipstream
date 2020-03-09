module Zipstream
  class CLI
    property config

    def initialize
      @config = Zipstream.config

      parse
    end

    private def parse
      optparse = OptionParser.new do |parser|
        parser.banner = <<-EOF
          NAME
              zipstream - is a command line tool that allows you to easily share files and directories over the network

          VERSION
              #{Zipstream::VERSION}

          SYNOPSIS
              zipstream PATH [options]

          If PATH is not specified it point to current directory

          OPTIONS
          EOF

        parser.on("-h", "--help", "give this help list") do
          puts parser
          exit
        end

        parser.on("-l", "--log", "logging of requests/responses") do
          config.log = true
        end

        parser.on("-w", "--web", "run WEB Server with the directory listing (default: CLI mode)") do
          config.web = true
        end

        parser.on("-H HOST", "--host=HOST", "the host (default: `#{config.host}`)") do |name|
          config.host = name
        end

        parser.on("-p PORT", "--port=PORT", "the port (default: `#{config.port}`)") do |name|
          unless name.chars.all?(&.number?)
            puts "ERROR: `#{name}` is not a valid port number"
            exit
          end

          config.port = name.to_i
        end

        parser.on("-f FORMAT", "--format=FORMAT", "the format of output archive, zip, tar or tgz. Only for CLI mode. (default: `#{config.format}`)") do |name|
          unless ["zip", "tar", "tgz"].includes?(name)
            puts "ERROR: `#{name}` is not a valid format, zip, tar, tgz"
            exit
          end

          config.format = name
        end

        parser.on("-o FILENAME", "--output=FILENAME", "the output file name without extension. Only for CLI mode. (default: `#{config.output}`)") do |name|
          config.output = name
        end

        parser.on("-e PATH", "--endpoint=PATH", "the URL path to the resource. Only for CLI mode. (default: `#{config.url_path}`)") do |name|
          unless name.lstrip("/").match(/(*UCP)^[[:word:]0-9_-]+$/)
            puts "ERROR: `#{name}` is not a valid url path, should contain only alphanumeric symbols"
            exit
          end
          config.url_path = name
        end

        parser.on("--user=user", "the username user for file retrieval") do |name|
          config.user = name
        end

        parser.on("--password=password", "the password password for file retrieval") do |name|
          config.password = name
        end

        parser.on("-V", "--version", "print program version") do
          default_target = Crystal::DESCRIPTION.split.last

          puts "zipstream #{Zipstream::VERSION} (#{default_target}) crystal/#{Crystal::VERSION} crystar/#{Crystar::VERSION}"
          puts "Release-Date: #{Time.parse_rfc2822(Config.release_date).to_s("%Y-%m-%d")}"
          exit
        end

        parser.invalid_option do |flag|
          puts "ERROR: #{flag} is not a valid option."
          puts parser
          exit
        end
      end

      optparse.parse

      config.path = File.expand_path(ARGV.pop? || config.path, Dir.current)

      unless File.exists?(config.path)
        puts "Path `#{config.path}` does not exist"
        exit
      end
    end
  end
end
