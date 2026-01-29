# Backend Setup Configuration
# This configuration creates the backend infrastructure (S3 + DynamoDB)
# Run this BEFORE configuring remote state in your main environments

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Initial setup uses local backend
  # After creating the backend infrastructure, migrate to remote state
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
      Purpose   = "Backend-Setup"
    }
  }
}

# Backend module for development environment
module "backend_dev" {
  source = "../../modules/backend"

  naming_prefix                 = "${var.project_name}-dev"
  environment                   = "dev"
  aws_region                    = var.aws_region
  state_retention_days          = 30
  enable_point_in_time_recovery = true
  create_backend_policy         = var.create_backend_policy
  enable_monitoring             = var.enable_monitoring
  log_retention_days            = 30

  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "Backend-Infrastructure"
  }
}

# Backend module for production environment
module "backend_prod" {
  source = "../../modules/backend"

  naming_prefix                 = "${var.project_name}-prod"
  environment                   = "prod"
  aws_region                    = var.aws_region
  state_retention_days          = 90
  enable_point_in_time_recovery = true
  create_backend_policy         = var.create_backend_policy
  enable_monitoring             = var.enable_monitoring
  log_retention_days            = 90

  tags = {
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "Terraform"
    Purpose     = "Backend-Infrastructure"
  }
}
