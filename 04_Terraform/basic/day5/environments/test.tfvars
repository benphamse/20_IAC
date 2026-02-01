# Test Environment Configuration
environment  = "test"
project_name = "web-app-test"

# Network Configuration
vpc_cidr_block       = "10.1.0.0/16"
public_subnet_1_cidr = "10.1.1.0/24"
availability_zone_1  = "us-east-1b"

# Compute Configuration
instance_type = "t2.small"
ami_value     = "ami-0b8607d2721c94a77"

# AWS Configuration
region = "us-east-1"

# Test Settings
enable_monitoring     = true
backup_retention_days = 5

# Tags
owner = "Ben Pham Dev" 
