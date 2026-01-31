locals {
  instance_type = "t2.micro"
  location      = var.region
  environment   = "production"
  vpc_cidr      = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }

  common_tags = {
    Project     = "Terraform Enterprise"
    Environment = local.environment
    Location    = local.location
    CreatedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}
