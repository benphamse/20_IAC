# Launch Template for EC2 instances
resource "aws_launch_template" "main" {
  name_prefix   = "${var.naming_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  # EBS optimization
  ebs_optimized = var.ebs_optimized

  # Monitoring
  monitoring {
    enabled = var.detailed_monitoring
  }

  # Instance metadata options
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # Block device mappings
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.encrypt_volumes
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.naming_prefix}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.naming_prefix}-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-launch-template"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  count = var.enable_auto_scaling ? 1 : 0

  name                      = "${var.naming_prefix}-asg"
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.naming_prefix}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Single EC2 Instance (when Auto Scaling is disabled)
resource "aws_instance" "main" {
  count = var.enable_auto_scaling ? 0 : var.instance_count

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]

  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data

  ebs_optimized = var.ebs_optimized
  monitoring    = var.detailed_monitoring

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.encrypt_volumes
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-instance-${count.index + 1}"
  })

  lifecycle {
    create_before_destroy = true
  }
}
