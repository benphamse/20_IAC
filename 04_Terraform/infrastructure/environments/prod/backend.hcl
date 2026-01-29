# S3 Backend Configuration for Production
bucket         = "your-terraform-state-bucket-prod"
key            = "environments/prod/terraform.tfstate"
region         = "ap-southeast-1"
encrypt        = true
dynamodb_table = "terraform-locks-prod"
