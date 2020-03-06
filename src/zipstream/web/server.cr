module Zipstream
  module Web
    class Server
      def config
        Config::INSTANCE
      end

      def run
        handlers = [] of HTTP::Handler

        if config.log
          handlers << LogHandler.new
        end

        if config.basic_auth?
          handlers << BasicAuthHandler.new(config.user.not_nil!, config.password.not_nil!)
        end

        handlers << StaticFileHandler.new(config.path)

        server = HTTP::Server.new(handlers)
        address = server.bind_tcp(config.host, config.port)

        puts "Serving `#{config.path}` at http://#{address}/#{config.url_path}"
        server.listen
      end
    end
  end
end
