# Production Environment Configuration
environment  = "prod"
project_name = "web-app-prod"

# Network Configuration
vpc_cidr_block       = "10.2.0.0/16"
public_subnet_1_cidr = "10.2.1.0/24"
availability_zone_1  = "us-east-1c"

# Compute Configuration
instance_type = "t2.medium"
ami_value     = "ami-0b8607d2721c94a77"

# AWS Configuration
region = "us-east-1"

# Production Settings
enable_monitoring     = true
backup_retention_days = 14

# Tags
owner = "Ben Pham Dev"
