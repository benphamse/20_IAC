# Backend module for Terraform state management
# This module creates S3 bucket and DynamoDB table for remote state storage

# Random suffix for unique naming
resource "random_id" "backend_suffix" {
  byte_length = 4
}

# S3 Bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.naming_prefix}-terraform-state-${random_id.backend_suffix.hex}"

  tags = merge(var.tags, {
    Name      = "${var.naming_prefix}-terraform-state"
    Purpose   = "Terraform State Storage"
    Component = "Backend"
  })
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.state_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.naming_prefix}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = merge(var.tags, {
    Name      = "${var.naming_prefix}-terraform-locks"
    Purpose   = "Terraform State Locking"
    Component = "Backend"
  })
}

# IAM policy for Terraform backend access
resource "aws_iam_policy" "terraform_backend_policy" {
  count       = var.create_backend_policy ? 1 : 0
  name        = "${var.naming_prefix}-terraform-backend-policy"
  description = "Policy for Terraform backend access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = aws_s3_bucket.terraform_state.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      }
    ]
  })

  tags = merge(var.tags, {
    Name      = "${var.naming_prefix}-terraform-backend-policy"
    Purpose   = "Terraform Backend Access"
    Component = "Backend"
  })
}

# CloudWatch Log Group for backend monitoring (optional)
resource "aws_cloudwatch_log_group" "terraform_backend" {
  count             = var.enable_monitoring ? 1 : 0
  name              = "/aws/terraform/backend/${var.naming_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name      = "${var.naming_prefix}-terraform-backend-logs"
    Purpose   = "Terraform Backend Monitoring"
    Component = "Backend"
  })
}
