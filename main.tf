locals {
  base_cidr_block = "10.0.0.0/8"
}

# ### AWS ACCOUNT ORG PREP ###

resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "ram.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_iam_service_linked_role" "ram" {
  aws_service_name = "ram.amazonaws.com"
}

### NETWORK | INSTANCES ###

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.base_cidr_block

  networks = [
    for i in range(0, 3) : {
      name     = i
      new_bits = 8
    }
  ]
}

module main {
  source = "./modules/network"

  providers = {
    aws = aws.main
  }

  name = "main"
  cidr = module.subnet_addrs.network_cidr_blocks[0]
  allowed_cidrs = values(module.subnet_addrs.network_cidr_blocks)
}

module playground {
  source = "./modules/network"

  providers = {
    aws = aws.playground
  }

  name = "playground"
  cidr = module.subnet_addrs.network_cidr_blocks[1]
  allowed_cidrs = values(module.subnet_addrs.network_cidr_blocks)
}

# ### PEERING ###

# module main_playground_peering {
#   source = "./modules/peering"

#   providers = {
#     aws.requester = aws.main
#     aws.accepter  = aws.playground
#   }

#   requester_vpc_id = module.main.vpc_id
#   accepter_vpc_id  = module.playground.vpc_id

#   requester_route_table_ids = [for table in module.main.route_tables : table.id]
#   accepter_route_table_ids  = [for table in module.playground.route_tables : table.id]
# }

### TRANSIT GATEWAY ### 

resource aws_ec2_transit_gateway gateway {
  provider = aws.gateway
  
  auto_accept_shared_attachments = "enable"

  tags = {
    Name = "transit-gateway"
  }
}

module main_attachment {
  source = "./modules/tgw-attachment"

  providers = {
    aws.gateway  = aws.gateway
    aws.attacher = aws.main
  }

  vpc_id      = module.main.vpc_id
  name        = "main"
  gateway_id  = aws_ec2_transit_gateway.gateway.id
  gateway_arn = aws_ec2_transit_gateway.gateway.arn
  subnet_ids  = module.main.subnet_ids

  base_cidr_block     = local.base_cidr_block
  vpc_route_table_ids = [for table in module.main.route_tables: table.id]
}

module playground_attachment {
  source = "./modules/tgw-attachment"

  providers = {
    aws.gateway  = aws.gateway
    aws.attacher = aws.playground
  }

  vpc_id      = module.playground.vpc_id
  name        = "playground"
  gateway_id  = aws_ec2_transit_gateway.gateway.id
  gateway_arn = aws_ec2_transit_gateway.gateway.arn
  subnet_ids  = module.playground.subnet_ids

  base_cidr_block     = local.base_cidr_block
  vpc_route_table_ids = [for table in module.playground.route_tables: table.id]
}
