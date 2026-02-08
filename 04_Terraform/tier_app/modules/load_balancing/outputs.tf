output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "lb_endpoint" {
  value = aws_lb.alb.dns_name
}

output "lb_target_group_name" {
  value = aws_lb_target_group.alb_target_group.name
}

output "lb_target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}