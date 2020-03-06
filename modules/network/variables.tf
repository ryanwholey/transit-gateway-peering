variable name {
  type = string
}

variable cidr {
  type = string
}

variable az_count {
  type = number
  default = 2
}

variable allowed_cidrs {
  type = list(string)
}
