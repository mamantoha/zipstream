class Socket
  struct IPAddress
    def self.from(sockaddr : LibC::SockaddrIn*, addrlen) : IPAddress
      case family = Family.new(sockaddr.value.sin_family)
      when Family::INET6
        new(sockaddr.as(LibC::SockaddrIn6*), addrlen.to_i)
      when Family::INET
        new(sockaddr.as(LibC::SockaddrIn*), addrlen.to_i)
      else
        raise "Unsupported family type: #{family} (#{family.value})"
      end
    end
  end
end
