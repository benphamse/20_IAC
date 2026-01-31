terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.30.0"
    }
  }

  backend "s3" {
    # Configure these values in backend.hcl or environment variables
    # bucket         = "your-terraform-state-bucket"
    # key            = "environments/dev/terraform.tfstate"
    # region         = "ap-southeast-1"
    # encrypt        = true
    # dynamodb_table = "terraform-locks"
  }
}
