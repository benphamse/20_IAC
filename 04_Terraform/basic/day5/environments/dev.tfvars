# Development Environment Configuration
environment  = "dev"
project_name = "web-app-dev"

# Network Configuration
vpc_cidr_block       = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
availability_zone_1  = "us-east-1a"

# Compute Configuration
instance_type = "t2.micro"
ami_value     = "ami-0b8607d2721c94a77"

# AWS Configuration
region = "us-east-1"

# Development Settings
enable_monitoring     = false
backup_retention_days = 3

# Tags
owner = "Ben Pham Dev" 
