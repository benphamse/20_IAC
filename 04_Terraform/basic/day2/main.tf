resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet in us-east-1a"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet in us-east-1b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "web_sg" {
  name        = "web"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "web_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.web_sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ssh from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.web_sg.id
  ip_protocol       = "-1"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "app_storage" {
  bucket = "my-terraform-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "app-storage"
    Environment = "dev"
  }
}

resource "aws_instance" "web_server1" {
  ami                    = "ami-0b8607d2721c94a77"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  user_data_base64       = base64encode(file("userdata.sh"))
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web_server1"
  }
}

resource "aws_instance" "web_server2" {
  ami                    = "ami-0b8607d2721c94a77"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  user_data_base64       = base64encode(file("userdata1.sh"))
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web_server2"
  }
}

#create alb
resource "aws_lb" "web_alb" {
  name               = "web-application-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.web_sg.id]
  subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name        = "web-application-lb"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-servers-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "web-servers-target-group"
  }
}

resource "aws_lb_target_group_attachment" "web_server_1_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}

resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }

  tags = {
    Name = "web-alb-listener"
  }
}

output "web_alb_dns_name" {
  description = "DNS name of the web application load balancer"
  value       = aws_lb.web_alb.dns_name
}
