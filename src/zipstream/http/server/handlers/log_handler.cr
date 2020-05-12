module Zipstream
  class LogHandler
    include HTTP::Handler

    def initialize(@io : IO = STDOUT)
    end

    def call(context : HTTP::Server::Context)
      elapsed_time = Time.measure { call_next(context) }
      elapsed_text = elapsed_text(elapsed_time)

      @io << message(context, elapsed_text)
      @io.flush
      @io

      context
    end

    private def message(context, elapsed_text) : String
      [
        remote_address(context),
        time,
        request_line(context),
        context.response.status_code,
        elapsed_text,
        user_agent(context),
        "\n",
      ].join(" ")
    end

    # Request/response process time.
    private def elapsed_text(elapsed)
      millis = elapsed.total_milliseconds

      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end

    # The IP address of the client (remote host) which made the request.
    private def remote_address(context)
      if remote_address = context.request.remote_address
        remote_address.to_s.split(":").first
      else
        "-"
      end
    end

    # The time that the request was received.
    #
    # The format is:
    # [day/month/year:hour:minute:second zone]
    #
    # e.g: [10/Oct/2000:13:55:36 -0700]
    private def time : String
      "[#{Time.local.to_s("%d/%b/%Y:%H:%M:%S %z")}]"
    end

    # The request line from the client is given in double quotes.
    #
    # The request line contains the method used by the client, requested resource,
    # and used protocol
    private def request_line(context) : String
      "\"#{context.request.method} #{context.request.resource} #{context.request.version}\""
    end

    private def user_agent(context)
      user_agent = context.request.headers["User-Agent"]? || "-"

      "\"#{user_agent}\""
    end
  end
end
