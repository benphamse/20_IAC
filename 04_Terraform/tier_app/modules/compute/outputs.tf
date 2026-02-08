output "frontend_autoscaling_group_name" {
  value = aws_autoscaling_group.frontend.name
}

output "backend_autoscaling_group_name" {
  value = aws_autoscaling_group.backend.name
}
