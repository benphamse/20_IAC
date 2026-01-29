resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  idle_timeout       = 400

  security_groups = [var.alb_security_group]
  depends_on      = [var.frontend_sg]

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name                 = "alb-target-group"
  port                 = var.alb_target_group_port
  protocol             = var.alb_target_group_protocol
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 300

  health_check {
    path = "/"
    port = "traffic-port"
  }

  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }

  tags = {
    Name = "alb_target_group"
  }

  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_target_group_port
  protocol          = var.alb_target_group_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  tags = {
    Name = "alb_listener"
  }
}