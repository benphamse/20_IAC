# ============================================================================
# ROOT TERRAGRUNT CONFIGURATION
# ============================================================================
# This file contains common configuration for all environments
# ============================================================================

# Configure Terragrunt to automatically retry on common errors
retryable_errors = [
  "(?s).*Error.*429.*Too Many Requests.*",
  "(?s).*Error.*timeout.*",
  "(?s).*Error.*connection reset.*"
]

# Retry configuration
retry_max_attempts       = 3
retry_sleep_interval_sec = 5

# Download Terraform source files
terraform_version_constraint = ">= 1.5.0"

# Common locals for reuse
locals {
  # Get AWS region from environment tfvars or use default
  aws_region = try(read_terragrunt_config("${get_terragrunt_dir()}/terragrunt.hcl").inputs.aws_region, "us-east-1")
}
