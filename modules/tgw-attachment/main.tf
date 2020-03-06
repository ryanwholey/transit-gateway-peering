data aws_caller_identity attacher {
  provider = aws.attacher
}

resource aws_ram_resource_share share {
  provider = aws.gateway

  name = "${var.name}-gateway-share"

  tags = {
    Name = "${var.name}-gateway-share"
  }
}

data aws_vpc attacher {
  provider = aws.attacher

  id = var.vpc_id
}

resource aws_ram_resource_association share {
  provider = aws.gateway

  resource_arn       = var.gateway_arn
  resource_share_arn = aws_ram_resource_share.share.id
}

resource aws_ram_principal_association share {
  provider = aws.gateway

  principal          = data.aws_caller_identity.attacher.account_id
  resource_share_arn = aws_ram_resource_share.share.id
}

resource aws_ec2_transit_gateway_vpc_attachment attachment {
  provider = aws.attacher

  depends_on = [
    aws_ram_principal_association.share,
    aws_ram_resource_association.share
  ]

  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.gateway_id
  vpc_id             = var.vpc_id

  tags = {
    Name = "${var.name}-attachment"
    Side = "Creator"
  }
}

# // Auto accepted
# resource aws_ec2_transit_gateway_vpc_attachment_accepter attachment {
#   provider = aws.gateway

#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachment.id

#   tags = {
#     Name = "${var.name}-attachment"
#     Side = "Accepter"
#   }
# }

data aws_ec2_transit_gateway gateway {
  provider = aws.gateway

  id = var.gateway_id
}

resource aws_ec2_transit_gateway_route route {
  provider = aws.gateway 

  destination_cidr_block         = data.aws_vpc.attacher.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.gateway.association_default_route_table_id
}

resource aws_route route {
  provider = aws.attacher

  count = length(var.vpc_route_table_ids)

  route_table_id         = element(var.vpc_route_table_ids, count.index)
  destination_cidr_block = var.base_cidr_block
  transit_gateway_id     = var.gateway_id
}
