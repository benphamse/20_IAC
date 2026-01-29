output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet[0].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[0].id
}

output "private_subnet_db_id" {
  value = aws_subnet.private_subnet_db[0].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "bastion_host_security_group" {
  value = aws_security_group.bastion_host_security_group
}


output "application_server_security_group_id" {
  value = aws_security_group.frontend_server_sg.id
}

output "database_server_security_group_id" {
  value = aws_security_group.db_server_sg.id
}

output "database_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group[0].id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "private_route_table_db_id" {
  value = aws_route_table.private_subnet_db_route_table.id
}

output "alb_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.*.name
}

output "rds_database_subnet_group_id" {
  value = aws_db_subnet_group.db_subnet_group.*.id
}

output "rds_security_group_id" {
  value = aws_security_group.db_server_sg.id
}

output "frontend_server_security_group_id" {
  value = aws_security_group.frontend_server_sg.id
}

output "backend_server_security_group_id" {
  value = aws_security_group.backend_server_sg.id
}

output "load_balancer_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "private_subnets_db" {
  value = aws_subnet.private_subnet_db.*.id
}