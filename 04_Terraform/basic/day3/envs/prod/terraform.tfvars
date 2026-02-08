ami_value     = "ami-0b8607d2721c94a77" # Amazon Linux 2 AMI for us-east-1
instance_type = "t3.small"              # Larger instance for production workload

# Production specific settings
environment          = "production"
vpc_cidr             = "10.1.0.0/16" # Different CIDR for prod to avoid conflicts
public_subnet_1_cidr = "10.1.1.0/24"
public_subnet_2_cidr = "10.1.2.0/24"

# Production tags
project_name = "web-app-prod"
owner        = "DevOps Team"

