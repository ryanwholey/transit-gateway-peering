locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_key_pair" "key" {
  key_name   = "admin-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

data aws_availability_zones available {
  state = "available"
}

resource aws_vpc network {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

resource aws_internet_gateway gateway {
  vpc_id = aws_vpc.network.id

  tags = {
    Name = var.name
  }
}

module public_subnets {
  source = "./modules/subnet"

  vpc_id    = aws_vpc.network.id
  azs       = local.azs
  is_public = true
  cidr      = var.cidr
  prefix    = var.name
}

resource aws_route_table public {
  vpc_id = aws_vpc.network.id

  tags = {
    Name      = "${var.name}-public"
    terraform = "true"
  }
}

resource aws_route requester_to_accepter {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource aws_route_table_association public {
  for_each = module.public_subnets.subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

module instance {
  source = "./modules/instance"

  subnet_ids = [
    for subnet in values(module.public_subnets.subnets): subnet.id
  ]

  vpc_id   = aws_vpc.network.id
  key_name = aws_key_pair.key.key_name
  name     = var.name

  allowed_cidrs = var.allowed_cidrs
}
