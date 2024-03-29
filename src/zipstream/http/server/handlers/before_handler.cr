module Zipstream
  class BeforeHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      decoded_path = URI.decode(context.request.path)

      if decoded_path != "/#{config.url_path}"
        context.response.respond_with_status(:not_found)

        return
      end

      call_next(context)
    end
  end
end
