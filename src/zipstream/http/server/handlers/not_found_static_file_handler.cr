module Zipstream
  class NotFoundStaticFileHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      path = File.join(config.path, context.request.path)

      unless File.exists?(path)
        context.response.respond_with_status(:not_found)

        return
      end

      call_next(context)
    end
  end
end
