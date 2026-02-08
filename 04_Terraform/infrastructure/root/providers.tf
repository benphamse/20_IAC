# ============================================================================
# DEVELOPMENT ENVIRONMENT PROVIDERS
# ============================================================================

terraform {
  required_version = ">= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30.0"
    }
  }

  # Backend configuration is loaded from backend.hcl
  backend "s3" {}
}
