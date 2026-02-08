output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web_alb.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.web_alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_target_group.arn
}

output "web_alb_dns_name" {
  description = "DNS name of the web application load balancer"
  value       = aws_lb.web_alb.dns_name
}
