output "config_recorder_name" {
  description = "Name of the Config configuration recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].name : null
}

output "config_delivery_channel_name" {
  description = "Name of the Config delivery channel"
  value       = var.enable_config ? aws_config_delivery_channel.main[0].name : null
}

output "config_bucket_arn" {
  description = "ARN of the Config S3 bucket"
  value       = var.enable_config ? aws_s3_bucket.config[0].arn : null
}

output "config_bucket_name" {
  description = "Name of the Config S3 bucket"
  value       = var.enable_config ? aws_s3_bucket.config[0].bucket : null
}

output "config_role_arn" {
  description = "ARN of the Config IAM role"
  value       = var.enable_config ? aws_iam_role.config[0].arn : null
}

output "config_role_name" {
  description = "Name of the Config IAM role"
  value       = var.enable_config ? aws_iam_role.config[0].name : null
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].name : null
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "cloudtrail_bucket_name" {
  description = "Name of the CloudTrail S3 bucket"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].bucket : null
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "security_hub_account_id" {
  description = "Security Hub account ID"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "config_rules" {
  description = "Map of Config rule names and their ARNs"
  value = {
    s3_bucket_public_access_prohibited = var.enable_config && var.enable_s3_compliance_rules ? aws_config_config_rule.s3_bucket_public_access_prohibited[0].arn : null
    s3_bucket_ssl_requests_only        = var.enable_config && var.enable_s3_compliance_rules ? aws_config_config_rule.s3_bucket_ssl_requests_only[0].arn : null
    encrypted_volumes                  = var.enable_config && var.enable_ec2_compliance_rules ? aws_config_config_rule.encrypted_volumes[0].arn : null
    root_access_key_check              = var.enable_config && var.enable_iam_compliance_rules ? aws_config_config_rule.root_access_key_check[0].arn : null
    iam_password_policy                = var.enable_config && var.enable_iam_compliance_rules ? aws_config_config_rule.iam_password_policy[0].arn : null
  }
}

output "security_hub_standards" {
  description = "Map of enabled Security Hub standards"
  value = {
    aws_foundational = var.enable_security_hub && var.enable_aws_foundational_standard ? aws_securityhub_standards_subscription.aws_foundational[0].standards_arn : null
    cis              = var.enable_security_hub && var.enable_cis_standard ? aws_securityhub_standards_subscription.cis[0].standards_arn : null
    pci_dss          = var.enable_security_hub && var.enable_pci_dss_standard ? aws_securityhub_standards_subscription.pci_dss[0].standards_arn : null
  }
}
