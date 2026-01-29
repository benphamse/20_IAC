# Outputs for backend module

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.region
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "backend_policy_arn" {
  description = "ARN of the IAM policy for backend access"
  value       = var.create_backend_policy ? aws_iam_policy.terraform_backend_policy[0].arn : null
}

output "backend_config" {
  description = "Backend configuration for use in other Terraform configurations"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "environments/${var.environment}/terraform.tfstate"
    region         = aws_s3_bucket.terraform_state.region
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
  sensitive = false
}

output "backend_config_hcl" {
  description = "Backend configuration in HCL format for backend.hcl file"
  value       = <<-EOT
# S3 Backend Configuration for ${title(var.environment)}
bucket         = "${aws_s3_bucket.terraform_state.bucket}"
key            = "environments/${var.environment}/terraform.tfstate"
region         = "${aws_s3_bucket.terraform_state.region}"
encrypt        = true
dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
EOT
}
