output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "project_name" {
  description = "Project name for current environment"
  value       = var.project_name
}

output "workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "web_server1_public_ip" {
  description = "Public IP address of web server 1"
  value       = module.compute.web_server1_public_ip
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = module.security.security_group_id
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}
