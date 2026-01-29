# S3 Backend Configuration for Development
bucket         = "your-terraform-state-bucket-dev"
key            = "environments/dev/terraform.tfstate"
region         = "ap-southeast-1"
encrypt        = true
dynamodb_table = "terraform-locks-dev"
