output vpc_id {
  value = aws_vpc.network.id
}

output route_tables {
  value = [aws_route_table.public]
}

output subnet_ids {
  value = [for subnet in module.public_subnets.subnets : subnet.id]
}

output instance {
  value = module.instance.instance
}
