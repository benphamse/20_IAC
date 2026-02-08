# Production Environment Configuration

# Project settings
project_name = "enterprise-infra"
environment  = "prod"
cost_center  = "production"

# AWS settings
aws_region = "us-east-1"

# Network configuration
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
enable_nat_gateway   = true

# Compute configuration
instance_type       = "t3.small"
enable_auto_scaling = true
min_size            = 2
max_size            = 6
desired_capacity    = 3

# Security configuration - More restrictive for production
allowed_cidr_blocks = ["0.0.0.0/0"] # Consider restricting this
enable_ssh_access   = true
ssh_cidr_blocks     = ["10.1.0.0/16"] # Only from VPC

# Additional tags
additional_tags = {
  Owner       = "DevOps Team"
  Application = "Web Application"
  Backup      = "daily"
  Monitoring  = "enabled"
  Critical    = "true"
}

# Extended service configuration - Production ready
enable_load_balancer = true # Enable for high availability
enable_caching       = true # Enable Redis for performance
enable_dns           = true # Enable Route53 management
enable_containers    = true # Enable ECS/Docker
enable_cicd          = true # Enable CI/CD pipeline

# DNS configuration
domain_name        = "prod.example.com"
create_hosted_zone = true

# Container configuration
container_image = "myapp:latest"

# CI/CD configuration
source_provider        = "GitHub"
source_branch          = "main"
create_codecommit_repo = false

# Serverless configuration
enable_serverless  = true # Enable Lambda + API Gateway
lambda_handler     = "index.handler"
lambda_runtime     = "python3.9"
lambda_in_vpc      = true # Deploy in VPC for security
create_api_gateway = true
api_path_part      = "api"

# Backup configuration - Comprehensive for production
enable_backup               = true
backup_ec2_instances        = true
backup_ebs_volumes          = true
enable_backup_notifications = true

# Governance configuration - Full compliance for production
enable_governance = true
