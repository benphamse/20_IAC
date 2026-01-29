# Development Environment Configuration

# Project settings
project_name = "enterprise-infra"
environment  = "dev"
cost_center  = "engineering"

# AWS settings
aws_region = "ap-southeast-1"

# Network configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
enable_nat_gateway   = false # Disabled for cost savings in dev

# Compute configuration
instance_type       = "t3.micro"
enable_auto_scaling = false
min_size            = 1
max_size            = 2
desired_capacity    = 1

# Security configuration
allowed_cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
enable_ssh_access   = true
ssh_cidr_blocks     = ["0.0.0.0/0"] # Restrict this in production

# Extended service configuration
enable_load_balancer = false # Enable for web apps
enable_caching       = false # Enable Redis/ElastiCache
enable_dns           = false # Enable Route53 management
enable_containers    = false # Enable ECS/Docker
enable_cicd          = false # Enable CI/CD pipeline

# DNS configuration (when enabled)
domain_name        = "dev.example.com"
create_hosted_zone = false

# Container configuration (when enabled)
container_image = "nginx:latest"

# CI/CD configuration (when enabled)
source_provider        = "CodeCommit"
source_branch          = "main"
create_codecommit_repo = true

# Additional tags
additional_tags = {
  Owner       = "DevOps Team"
  Application = "Web Application"
  Backup      = "daily"
  Stack       = "full-stack"
}

# Serverless configuration
enable_serverless  = false # Enable Lambda + API Gateway
lambda_handler     = "index.handler"
lambda_runtime     = "python3.9"
lambda_in_vpc      = false
create_api_gateway = true
api_path_part      = "api"

# Backup configuration
enable_backup               = false # Enable AWS Backup
backup_ec2_instances        = false
backup_ebs_volumes          = false
enable_backup_notifications = false

# Governance configuration
enable_governance = false # Enable compliance and governance tools
