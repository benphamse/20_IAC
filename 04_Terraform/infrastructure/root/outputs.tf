# ============================================================================
# DEVELOPMENT ENVIRONMENT OUTPUTS
# ============================================================================
# Pass through outputs from shared infrastructure
# ============================================================================

# Networking
output "vpc_id" {
  description = "VPC ID"
  value       = module.infrastructure.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.infrastructure.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.infrastructure.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.infrastructure.private_subnet_ids
}

# Security
output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.infrastructure.web_security_group_id
}

# Compute
output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.infrastructure.instance_ids
}

output "instance_private_ips" {
  description = "EC2 instance private IPs"
  value       = module.infrastructure.instance_private_ips
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = module.infrastructure.instance_public_ips
  sensitive   = true
}

output "autoscaling_group_id" {
  description = "Auto Scaling Group ID"
  value       = module.infrastructure.autoscaling_group_id
}

# Load Balancer
output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.infrastructure.alb_dns_name
}

# Storage
output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = module.infrastructure.s3_bucket_id
}

# Monitoring
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = module.infrastructure.cloudwatch_log_group_name
}

# Caching
output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = module.infrastructure.redis_endpoint
  sensitive   = true
}

# DNS
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.infrastructure.route53_zone_id
}

# Containers
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.infrastructure.ecs_cluster_name
}

# CI/CD
output "codepipeline_name" {
  description = "CodePipeline name"
  value       = module.infrastructure.codepipeline_name
}

# Serverless
output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.infrastructure.lambda_function_name
}

output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = module.infrastructure.api_gateway_url
}

# Environment Info
output "environment" {
  description = "Environment name"
  value       = module.infrastructure.environment
}

output "project_name" {
  description = "Project name"
  value       = module.infrastructure.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = module.infrastructure.aws_region
}
