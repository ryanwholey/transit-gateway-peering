provider aws {
  region = "us-west-2"
}

provider aws {
  alias  = "main"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::695834901730:role/admin"
  }
}

provider aws {
  alias  = "playground"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::199001079875:role/admin"
  }
}

provider aws {
  alias  = "gateway"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::993222770595:role/admin"
  }
}
