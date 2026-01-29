output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.security.web_security_group_id
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.compute.instance_ids
}

output "instance_private_ips" {
  description = "EC2 instance private IPs"
  value       = module.compute.instance_private_ips
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = module.compute.instance_public_ips
  sensitive   = true
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = module.compute.launch_template_id
}

output "autoscaling_group_id" {
  description = "Auto Scaling Group ID"
  value       = module.compute.autoscaling_group_id
}
