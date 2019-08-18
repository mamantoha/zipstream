require "crypto/subtle"

module Zipstream
  class BasicAuthHandler
    include HTTP::Handler

    BASIC                 = "Basic"
    AUTH                  = "Authorization"
    AUTH_MESSAGE          = "Could not verify your access level for that URL.\nYou have to login with proper credentials"
    HEADER_LOGIN_REQUIRED = "Basic realm=\"Login Required\""

    def initialize(@username : String, @password : String)
    end

    def call(context)
      if context.request.headers[AUTH]?
        if value = context.request.headers[AUTH]
          if value.size > 0 && value.starts_with?(BASIC)
            if authorize?(value)
              return call_next(context)
            end
          end
        end
      end

      headers = HTTP::Headers.new
      context.response.status_code = 401
      context.response.headers["WWW-Authenticate"] = HEADER_LOGIN_REQUIRED
      context.response.print AUTH_MESSAGE
    end

    private def authorize?(value : String) : Bool
      given_username, given_password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")

      return false unless Crypto::Subtle.constant_time_compare(@username, given_username)
      return false unless Crypto::Subtle.constant_time_compare(@password, given_password)

      true
    end
  end
end
