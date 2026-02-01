# ============================================================================
# PRODUCTION ENVIRONMENT VALUES
# ============================================================================

# Common
environment  = "prod"
aws_region   = "us-east-1"
project_name = "terraform-enterprise"
cost_center  = "production"

# Network - larger for prod
vpc_cidr             = "10.100.0.0/16"
public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
private_subnet_cidrs = ["10.100.10.0/24", "10.100.20.0/24", "10.100.30.0/24"]
enable_nat_gateway   = true

# Compute - production-grade
instance_type       = "t3.medium"
enable_auto_scaling = true
min_size            = 2
max_size            = 10
desired_capacity    = 3

# Security - strict
enable_ssh_access   = false
ssh_cidr_blocks     = []
allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]

# Services - full features
enable_load_balancer  = true
enable_storage_module = true
enable_monitoring     = true
log_retention_days    = 90
enable_caching        = true
enable_dns            = true
enable_containers     = true
enable_cicd           = true
enable_serverless     = false
enable_backup         = true
enable_governance     = true

# Tags
additional_tags = {
  Tier         = "production"
  Compliance   = "required"
  BackupPolicy = "daily"
  Owner        = "ops-team"
}
