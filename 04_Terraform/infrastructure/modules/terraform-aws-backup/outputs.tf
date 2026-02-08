output "backup_vault_arn" {
  description = "ARN of the backup vault"
  value       = aws_backup_vault.main.arn
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = aws_backup_vault.main.name
}

output "backup_plan_arn" {
  description = "ARN of the backup plan"
  value       = aws_backup_plan.main.arn
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = aws_backup_plan.main.id
}

output "backup_plan_version" {
  description = "Version of the backup plan"
  value       = aws_backup_plan.main.version
}

output "backup_role_arn" {
  description = "ARN of the backup IAM role"
  value       = aws_iam_role.backup.arn
}

output "backup_role_name" {
  description = "Name of the backup IAM role"
  value       = aws_iam_role.backup.name
}

output "ec2_backup_selection_id" {
  description = "ID of the EC2 backup selection"
  value       = var.backup_ec2_instances ? aws_backup_selection.ec2[0].id : null
}

output "rds_backup_selection_id" {
  description = "ID of the RDS backup selection"
  value       = var.backup_rds_instances ? aws_backup_selection.rds[0].id : null
}

output "ebs_backup_selection_id" {
  description = "ID of the EBS backup selection"
  value       = var.backup_ebs_volumes ? aws_backup_selection.ebs[0].id : null
}

output "dynamodb_backup_selection_id" {
  description = "ID of the DynamoDB backup selection"
  value       = var.backup_dynamodb_tables ? aws_backup_selection.dynamodb[0].id : null
}

output "efs_backup_selection_id" {
  description = "ID of the EFS backup selection"
  value       = var.backup_efs_filesystems ? aws_backup_selection.efs[0].id : null
}

output "backup_notifications_topic_arn" {
  description = "ARN of the backup notifications SNS topic"
  value       = var.enable_backup_notifications ? aws_sns_topic.backup_notifications[0].arn : null
}

output "backup_notifications_topic_name" {
  description = "Name of the backup notifications SNS topic"
  value       = var.enable_backup_notifications ? aws_sns_topic.backup_notifications[0].name : null
}
