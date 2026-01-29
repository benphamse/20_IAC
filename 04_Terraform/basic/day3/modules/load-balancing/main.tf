#create alb
resource "aws_lb" "web_alb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.security_group_id]
  subnets         = [var.subnet_1_id, var.subnet_2_id]

  tags = {
    Name        = var.lb_name
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-servers-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

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
  target_id        = var.web_server1_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.web_server2_id
  port             = 80
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

