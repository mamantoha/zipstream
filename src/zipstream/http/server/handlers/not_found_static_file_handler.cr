module Zipstream
  class NotFoundStaticFileHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      decoded_path = URI.decode(context.request.path)

      path = File.join(config.path, decoded_path)

      unless File.exists?(path)
        context.response.respond_with_status(:not_found)

        return
      end

      call_next(context)
    end
  end
end
