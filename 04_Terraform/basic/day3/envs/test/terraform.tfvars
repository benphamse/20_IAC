ami_value     = "ami-0b8607d2721c94a77" # Amazon Linux 2 AMI for us-east-1
instance_type = "t2.micro"              # Small instance for testing

# Test specific settings
environment          = "test"
vpc_cidr             = "10.2.0.0/16" # Different CIDR for test environment
public_subnet_1_cidr = "10.2.1.0/24"
public_subnet_2_cidr = "10.2.2.0/24"

# Test tags
project_name = "web-app-test"
owner        = "QA Team"

