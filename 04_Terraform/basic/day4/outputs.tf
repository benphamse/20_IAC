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
