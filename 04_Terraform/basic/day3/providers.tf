provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Development"
      Project     = "Terraform-Demo"
      Owner       = "Ben Pham Dev"
      ManagedBy   = "Terraform"
    }
  }
}
