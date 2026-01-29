output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.main.latest_version
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].id : null
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = var.enable_auto_scaling ? aws_autoscaling_group.main[0].arn : null
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = var.enable_auto_scaling ? [] : aws_instance.main[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = var.enable_auto_scaling ? [] : aws_instance.main[*].private_ip
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = var.enable_auto_scaling ? [] : aws_instance.main[*].public_ip
}
