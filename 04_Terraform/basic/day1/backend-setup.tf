# Backend setup for Terraform state management
# This file creates the S3 bucket and DynamoDB table for state locking

# Generate a random string to append to the bucket name for uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the S3 bucket for state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "tf-state-${random_string.suffix.result}"
  force_destroy = true # This allows Terraform to delete bucket even with objects

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
    Purpose     = "terraform-state"
  }
}

# Enable versioning on the S3 bucket to keep state history
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for state locking (optional but recommended)
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock-${random_string.suffix.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "dev"
    Purpose     = "terraform-state-locking"
  }
}

# Output the bucket name and DynamoDB table name
output "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "backend_config" {
  description = "Backend configuration for use in other Terraform configurations"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "day1/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = aws_dynamodb_table.terraform_lock.name
    encrypt        = true
  }
}
