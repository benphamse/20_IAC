terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Specify the source of the AWS provider
      version = "~> 6.2"        # Use a version of the AWS provider that is compatible with version
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }
  }
}


provider "aws" {
  region = "ap-southeast-1" # Set the AWS region to Singapore
}

provider "vault" {
  address          = "http://18.142.236.206:8200" # Set the Vault server address\
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "c0c4f6d3-c653-7bb9-f394-e6ecee36ce86"
      secret_id = "5d036af6-f346-6b04-5340-edb449e7ff55"
    }
  }
}