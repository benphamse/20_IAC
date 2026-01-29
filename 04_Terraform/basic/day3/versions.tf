terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }


  # You can uncomment and configure this if you want to use remote state
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "terraform/state/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

