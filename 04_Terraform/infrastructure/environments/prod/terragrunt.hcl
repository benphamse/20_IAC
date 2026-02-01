# ============================================================================
# TERRAGRUNT CONFIGURATION - PRODUCTION ENVIRONMENT
# ============================================================================

# Include root terragrunt.hcl if it exists
include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

# Terraform source - point to root configuration
terraform {
  source = "../../root"
}

# Remote state configuration
remote_state {
  backend = "s3"
  
  config = {
    bucket         = "your-terraform-state-bucket"  # TODO: Update with your bucket
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"  # TODO: Update with your table
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
}
EOF
}

# Input variables from terraform.tfvars
inputs = {
  # Will automatically use terraform.tfvars in this directory
}
