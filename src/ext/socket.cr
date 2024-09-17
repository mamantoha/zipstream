class Socket
  def self.ip_address_list : Array(Socket::IPAddress)
    ptr = Pointer(Pointer(LibC::Ifaddrs)).malloc(1)
    ret = LibC.getifaddrs(ptr)

    if ret == -1
      raise raise Socket::Error.new("Failed to get network interfaces")
    end

    list = [] of Socket::IPAddress
    addr = ptr.value

    while addr
      if addr.value.ifa_addr.null?
        addr = addr.value.ifa_next
        next
      end

      sockaddr_in = addr.value.ifa_addr.as(Pointer(LibC::SockaddrIn))

      unless sockaddr_in.value.sin_family.in?([Socket::Family::INET.to_i, Socket::Family::INET6.to_i])
        addr = addr.value.ifa_next
        next
      end

      ip_address = Socket::IPAddress.from(sockaddr_in, sizeof(typeof(sockaddr_in)))

      list << ip_address

      addr = addr.value.ifa_next
    end

    LibC.freeifaddrs(ptr.value)

    list
  end
end
