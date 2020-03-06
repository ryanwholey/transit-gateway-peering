variable subnet_ids {
  type = list(string)
}

variable name {
  type = string
}

variable vpc_id {
  type = string
}

variable allowed_cidrs {
  type = list(string)
}

variable key_name {
  type = string
}
