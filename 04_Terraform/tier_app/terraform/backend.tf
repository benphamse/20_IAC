terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
    }
  }

  backend "s3" {
    bucket  = "three-tier-vpc-terraform-state"
    key     = "terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}