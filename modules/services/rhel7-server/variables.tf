variable gateway {
  type      = string
  default   = "192.168.2.1"
}

variable interface {
  type      = string
  default   = "eth0"
}

variable subnet {
  type      = string
  default   = "255.255.255.0"
}

variable ipaddy {
  type      = string
  default   = ""
}

variable hostname {
  type      = string
  default   = ""
}

variable tshirt {
  type      = string
  default   = ""
}

variable mem {
  type      = string
  default   = "4096"
}

variable cpu_num {
  type      = number
  default   = 2
}

variable vmpool {
  type      = string
  default   = ""
}
