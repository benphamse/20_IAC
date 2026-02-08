resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ssh_key
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = var.ssh_key
  }
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${var.ssh_key}-pem"
  file_permission = "0400"
}


# launch template for bastion host
resource "aws_launch_template" "bastion" {
  name_prefix   = "bastion"
  image_id      = data.aws_ssm_parameter.ami.value
  instance_type = var.instance_type
  key_name      = var.key_name
  description   = "Bastion host launch template"
  tags          = var.tags

  vpc_security_group_ids = [var.bastion_security_group_id]
}


resource "aws_autoscaling_group" "bastion" {
  name                = "bastion"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "bastion"
  }
}

# launch template for frontend host
resource "aws_launch_template" "frontend" {
  name_prefix            = "frontend"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.frontend_security_group_id]
  user_data              = filebase64("${path.root}/install_apache.sh")
  description            = "Frontend host launch template"

  tags = {
    Name = "frontend"
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                = "frontend"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [var.alb_target_group_arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "frontend"
  }
}

# launch template for backend host
resource "aws_launch_template" "backend" {
  name_prefix            = "backend"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.backend_security_group_id]
  user_data              = filebase64("${path.root}/install_node.sh")

  tags = {
    Name = "backend"
  }
}


resource "aws_autoscaling_group" "backend" {
  name                = "backend"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [var.alb_target_group_arn]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "backend"
  }
}
