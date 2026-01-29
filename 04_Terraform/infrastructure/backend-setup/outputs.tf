# Outputs for backend setup

output "dev_backend_config" {
  description = "Backend configuration for development environment"
  value       = module.backend_dev.backend_config_hcl
}

output "prod_backend_config" {
  description = "Backend configuration for production environment"
  value       = module.backend_prod.backend_config_hcl
}

output "dev_s3_bucket" {
  description = "S3 bucket name for development environment"
  value       = module.backend_dev.s3_bucket_name
}

output "prod_s3_bucket" {
  description = "S3 bucket name for production environment"
  value       = module.backend_prod.s3_bucket_name
}

output "dev_dynamodb_table" {
  description = "DynamoDB table name for development environment"
  value       = module.backend_dev.dynamodb_table_name
}

output "prod_dynamodb_table" {
  description = "DynamoDB table name for production environment"
  value       = module.backend_prod.dynamodb_table_name
}

output "setup_complete_message" {
  description = "Message indicating setup completion"
  value       = <<-EOT
🎉 Backend infrastructure setup completed!

Next steps:
1. Update your environment backend.hcl files with the configurations above
2. Run 'terraform init -backend-config=backend.hcl' in your environment directories
3. Run 'terraform init -migrate-state' to migrate existing state (if any)

Development Backend Config:
${module.backend_dev.backend_config_hcl}

Production Backend Config:
${module.backend_prod.backend_config_hcl}
EOT
}
