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

        handlers << HiddenStaticFileHandler.new(config)

        if config.basic_auth?
          handlers << BasicAuthHandler.new(config.user.not_nil!, config.password.not_nil!)
        end

        handlers << StaticFileHandler.new(config.path, match_hidden: config.hidden?)

        server = HTTP::Server.new(handlers)
        address = server.bind_tcp(config.host, config.port)

        unless File.readable?(config.path)
          puts "#{config.path} : Permission denied"
          exit
        end

        shutdown = ->(_s : Signal) do
          puts
          puts "See you later, alligator!"
          server.close
          exit
        end

        Signal::INT.trap &shutdown
        Signal::TERM.trap &shutdown

        STDOUT.flush

        server.listen unless config.env == "test"
      end
    end
  end
end
