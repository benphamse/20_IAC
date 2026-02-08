# S3 Backend Configuration for Production
bucket         = "your-terraform-state-bucket-prod"
key            = "environments/prod/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
lock_file      = true