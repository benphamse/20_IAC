# Development Environment Configuration
ami_value     = "ami-0b8607d2721c94a77" # Amazon Linux 2 AMI for us-east-1
instance_type = "t2.micro"              # Small instance for development

# Development specific settings
environment          = "development"
vpc_cidr             = "10.0.0.0/16" # Development VPC CIDR
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"

# Development tags
project_name = "web-app-dev"
owner        = "Development Team"

