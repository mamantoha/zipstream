module Zipstream
  module Web
    class Server
      def config
        Config::INSTANCE
      end

      def run
        handlers = [] of HTTP::Handler

        if config.log?
          handlers << LogHandler.new
        end

        handlers << NotFoundStaticFileHandler.new(config)
        handlers << HiddenStaticFileHandler.new(config)
        handlers << SymlinkStaticFileHandler.new(config)

        if config.basic_auth?
          handlers << BasicAuthHandler.new(config.user.to_s, config.password.to_s)
        end

        handlers << StaticFileHandler.new(config.path, match_hidden: config.hidden?, follow_symlinks: !config.no_symlinks?)

        server = HTTP::Server.new(handlers)
        server.bind_tcp(config.host, config.port)

        unless File::Info.readable?(config.path)
          puts "#{config.path} : Permission denied"
          exit
        end

        Process.on_terminate { shutdown(server) }

        STDOUT.flush

        server.listen unless config.env == "test"
      end

      private def shutdown(server)
        puts
        puts "See you later, alligator!"
        server.close
        exit
      end
    end
  end
end
