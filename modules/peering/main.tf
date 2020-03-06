data aws_caller_identity accepter {
  provider = aws.accepter
}

resource aws_vpc_peering_connection requester {
  provider = aws.requester

  vpc_id        = var.requester_vpc_id

  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = data.aws_caller_identity.accepter.account_id
}

resource aws_vpc_peering_connection_accepter accepter {
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true
}

# data aws_route_tables accepter {
#   provider = aws.accepter
#   vpc_id   = var.accepter_vpc_id

#   filter {
#     name   = "tag:terraform"
#     values = ["true"]
#   }
# }

# data aws_route_tables requester {
#   provider = aws.requester

#   vpc_id   = var.requester_vpc_id

#   filter {
#     name   = "tag:terraform"
#     values = ["true"]
#   }
# }

data aws_vpc accepter {
  provider = aws.accepter

  id = var.accepter_vpc_id
}

data aws_vpc requester {
  provider = aws.requester

  id = var.requester_vpc_id
}

resource aws_route requester_to_accepter {
  provider = aws.requester

  # count    = length(data.aws_route_tables.requester.ids)
  count = length(var.requester_route_table_ids)

  # route_table_id            = element(tolist(data.aws_route_tables.requester.ids), count.index)
  route_table_id            = element(var.requester_route_table_ids, count.index)
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}

resource aws_route accepter_to_requester {
  provider = aws.accepter

  # count    = length(data.aws_route_tables.accepter.ids)
  count = length(var.accepter_route_table_ids)

  # route_table_id            = element(tolist(data.aws_route_tables.accepter.ids), count.index)
  route_table_id = element(var.accepter_route_table_ids, count.index)
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
}
