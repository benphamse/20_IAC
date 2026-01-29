resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_vpc_public_subnet_${count.index}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route" "public_subnet_rt" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


# Private Subnets
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id # TODO: change to private subnet

  tags = {
    Name = "nat_gateway"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_vpc_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# DB Subnet
resource "aws_subnet" "private_subnet_db" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.private_subnet_count
  cidr_block              = "10.0.${30 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_vpc_private_subnet_db_${count.index}"
  }
}

resource "aws_route_table" "private_subnet_db_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private_subnet_db_route_table"
  }
}


# Security Groups

# Security Group for Bastion Host
resource "aws_security_group" "bastion_host_security_group" {
  name        = "bastion_host_security_group"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.vpc.id

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = var.bastion_host_allowed_cidr_blocks
      description      = "Allow SSH access"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all outbound traffic"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "bastion_host_security_group"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "load_balancer_security_group" {
  name        = "load_balancer_security_group"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "load_balancer_security_group_for_frontend"
  }
}

resource "aws_security_group_rule" "lb_sg_rule_ingress" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "Allow HTTP traffic from anywhere"
}

resource "aws_security_group_rule" "lb_sg_rule_egress" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  description = "Allow all outbound traffic"
}

# Security Group for Frontend Server
resource "aws_security_group" "frontend_server_sg" {
  name        = "frontend_server_sg"
  description = "Security group for the application server"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "frontend_server_sg"
  }
}

resource "aws_security_group_rule" "frontend_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_host_security_group.id
  security_group_id        = aws_security_group.frontend_server_sg.id

  description = "Allow SSH access from bastion host"
}

resource "aws_security_group_rule" "frontend_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer_security_group.id
  security_group_id        = aws_security_group.frontend_server_sg.id

  description = "Allow HTTP access from load balancer"
}

resource "aws_security_group_rule" "frontend_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_server_sg.id

  description = "Allow all outbound traffic"
}

#Security Group for Backend Server
resource "aws_security_group" "backend_server_sg" {
  name        = "backend_server_sg"
  description = "Security group for the backend server"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "backend_server_sg"
  }
}

resource "aws_security_group_rule" "backend_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_host_security_group.id
  security_group_id        = aws_security_group.backend_server_sg.id

  description = "Allow SSH access from bastion host"
}

resource "aws_security_group_rule" "backend_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.frontend_server_sg.id
  security_group_id        = aws_security_group.backend_server_sg.id

  description = "Allow HTTP access from frontend server"
}

resource "aws_security_group_rule" "backend_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend_server_sg.id

  description = "Allow all outbound traffic from backend server"
}


#Security Group for Database Server
resource "aws_security_group" "db_server_sg" {
  name        = "db_server_sg"
  description = "Security group for the database server"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "db_server_sg"
  }
}

resource "aws_security_group_rule" "database_mysql_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend_server_sg.id
  security_group_id        = aws_security_group.db_server_sg.id

  description = "Allow MySQL access from backend server"
}

resource "aws_security_group_rule" "database_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_server_sg.id

  description = "Allow all outbound traffic from database server"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count       = var.database_subnet_count == true ? 1 : 0
  name        = "db_subnet_group"
  subnet_ids  = aws_subnet.private_subnet_db[*].id
  description = "Subnet group for the database"

  tags = {
    Name = "db_subnet_group"
  }
}