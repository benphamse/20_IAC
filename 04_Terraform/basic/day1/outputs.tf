# Output example
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
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