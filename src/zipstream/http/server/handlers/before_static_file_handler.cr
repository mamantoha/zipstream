module Zipstream
  class BeforeStaticFileHandler
    include HTTP::Handler

    property config

    def initialize(@config : Config)
    end

    def call(context)
      if !config.hidden && hidden?(context)
        context.response.respond_with_status(:not_found)

        return
      end

      call_next(context)
    end

    private def hidden?(context)
      context.request.path.split("/").any?(&.starts_with?("."))
    end
  end
end
