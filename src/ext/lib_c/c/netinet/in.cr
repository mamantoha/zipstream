lib LibC
  struct Ifaddrs
    ifa_next : Pointer(Ifaddrs)
    ifa_name : UInt64
    ifa_flags : UInt32
    ifa_addr : Pointer(Void)
    ifa_netmask : Pointer(Void)
    ifa_broadaddr : Pointer(Void)
    ifa_data : Pointer(Void)
  end

  fun getifaddrs(addrs : Pointer(Pointer(Ifaddrs))) : Int32
  fun freeifaddrs(addrs : Pointer(Ifaddrs)) : Void
end
