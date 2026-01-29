variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Backup Vault Configuration
variable "kms_key_arn" {
  description = "ARN of the KMS key for backup vault encryption"
  type        = string
  default     = null
}

# Backup Plan Configuration
variable "daily_backup_schedule" {
  description = "Cron expression for daily backup schedule"
  type        = string
  default     = "cron(0 5 ? * * *)" # 5 AM daily
}

variable "cold_storage_after_days" {
  description = "Days after which backups are moved to cold storage"
  type        = number
  default     = 30
}

variable "delete_after_days" {
  description = "Days after which backups are deleted"
  type        = number
  default     = 120
}

# Cross-region backup configuration
variable "cross_region_vault_arn" {
  description = "ARN of cross-region backup vault"
  type        = string
  default     = null
}

variable "cross_region_cold_storage_after_days" {
  description = "Days after which cross-region backups are moved to cold storage"
  type        = number
  default     = 30
}

variable "cross_region_delete_after_days" {
  description = "Days after which cross-region backups are deleted"
  type        = number
  default     = 120
}

# Weekly backup configuration
variable "enable_weekly_backup" {
  description = "Enable weekly backup rule"
  type        = bool
  default     = false
}

variable "weekly_backup_schedule" {
  description = "Cron expression for weekly backup schedule"
  type        = string
  default     = "cron(0 5 ? * SUN *)" # 5 AM every Sunday
}

variable "weekly_cold_storage_after_days" {
  description = "Days after which weekly backups are moved to cold storage"
  type        = number
  default     = 30
}

variable "weekly_delete_after_days" {
  description = "Days after which weekly backups are deleted"
  type        = number
  default     = 365
}

# Monthly backup configuration
variable "enable_monthly_backup" {
  description = "Enable monthly backup rule"
  type        = bool
  default     = false
}

variable "monthly_backup_schedule" {
  description = "Cron expression for monthly backup schedule"
  type        = string
  default     = "cron(0 5 1 * ? *)" # 5 AM on the 1st of every month
}

variable "monthly_cold_storage_after_days" {
  description = "Days after which monthly backups are moved to cold storage"
  type        = number
  default     = 30
}

variable "monthly_delete_after_days" {
  description = "Days after which monthly backups are deleted"
  type        = number
  default     = 2555 # 7 years
}

# Resource selection configuration
variable "backup_ec2_instances" {
  description = "Enable backup for EC2 instances"
  type        = bool
  default     = false
}

variable "ec2_instance_arns" {
  description = "List of EC2 instance ARNs to backup"
  type        = list(string)
  default     = []
}

variable "ec2_backup_tags" {
  description = "Tags to identify EC2 instances for backup"
  type = object({
    key   = string
    value = string
  })
  default = {
    key   = "Backup"
    value = "true"
  }
}

variable "backup_rds_instances" {
  description = "Enable backup for RDS instances"
  type        = bool
  default     = false
}

variable "rds_instance_arns" {
  description = "List of RDS instance ARNs to backup"
  type        = list(string)
  default     = []
}

variable "rds_backup_tags" {
  description = "Tags to identify RDS instances for backup"
  type = object({
    key   = string
    value = string
  })
  default = {
    key   = "Backup"
    value = "true"
  }
}

variable "backup_ebs_volumes" {
  description = "Enable backup for EBS volumes"
  type        = bool
  default     = false
}

variable "ebs_volume_arns" {
  description = "List of EBS volume ARNs to backup"
  type        = list(string)
  default     = []
}

variable "ebs_backup_tags" {
  description = "Tags to identify EBS volumes for backup"
  type = object({
    key   = string
    value = string
  })
  default = {
    key   = "Backup"
    value = "true"
  }
}

variable "backup_dynamodb_tables" {
  description = "Enable backup for DynamoDB tables"
  type        = bool
  default     = false
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs to backup"
  type        = list(string)
  default     = []
}

variable "dynamodb_backup_tags" {
  description = "Tags to identify DynamoDB tables for backup"
  type = object({
    key   = string
    value = string
  })
  default = {
    key   = "Backup"
    value = "true"
  }
}

variable "backup_efs_filesystems" {
  description = "Enable backup for EFS file systems"
  type        = bool
  default     = false
}

variable "efs_filesystem_arns" {
  description = "List of EFS file system ARNs to backup"
  type        = list(string)
  default     = []
}

variable "efs_backup_tags" {
  description = "Tags to identify EFS file systems for backup"
  type = object({
    key   = string
    value = string
  })
  default = {
    key   = "Backup"
    value = "true"
  }
}

# Notification configuration
variable "enable_backup_notifications" {
  description = "Enable backup job notifications"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for backup notifications"
  type        = string
  default     = null
}
