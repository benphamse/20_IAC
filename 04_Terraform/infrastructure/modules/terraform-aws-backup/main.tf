# AWS Backup Vault
resource "aws_backup_vault" "main" {
  name        = "${var.naming_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-backup-vault"
  })
}

# AWS Backup Plan
resource "aws_backup_plan" "main" {
  name = "${var.naming_prefix}-backup-plan"

  # Daily Backup Rule
  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.daily_backup_schedule

    lifecycle {
      cold_storage_after = var.cold_storage_after_days
      delete_after       = var.delete_after_days
    }

    recovery_point_tags = merge(var.tags, {
      BackupType = "Daily"
    })

    copy_action {
      destination_vault_arn = var.cross_region_vault_arn != null ? var.cross_region_vault_arn : aws_backup_vault.main.arn

      lifecycle {
        cold_storage_after = var.cross_region_cold_storage_after_days
        delete_after       = var.cross_region_delete_after_days
      }
    }
  }

  # Weekly Backup Rule (optional)
  dynamic "rule" {
    for_each = var.enable_weekly_backup ? [1] : []
    content {
      rule_name         = "weekly_backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.weekly_backup_schedule

      lifecycle {
        cold_storage_after = var.weekly_cold_storage_after_days
        delete_after       = var.weekly_delete_after_days
      }

      recovery_point_tags = merge(var.tags, {
        BackupType = "Weekly"
      })
    }
  }

  # Monthly Backup Rule (optional)
  dynamic "rule" {
    for_each = var.enable_monthly_backup ? [1] : []
    content {
      rule_name         = "monthly_backup"
      target_vault_name = aws_backup_vault.main.name
      schedule          = var.monthly_backup_schedule

      lifecycle {
        cold_storage_after = var.monthly_cold_storage_after_days
        delete_after       = var.monthly_delete_after_days
      }

      recovery_point_tags = merge(var.tags, {
        BackupType = "Monthly"
      })
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-backup-plan"
  })
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.naming_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-backup-role"
  })
}

# IAM Policy Attachment for AWS Backup
resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Backup Selection for EC2 Instances
resource "aws_backup_selection" "ec2" {
  count = var.backup_ec2_instances ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.naming_prefix}-ec2-backup"
  plan_id      = aws_backup_plan.main.id

  resources = var.ec2_instance_arns

  dynamic "condition" {
    for_each = length(var.ec2_backup_tags) > 0 ? [1] : []
    content {
      string_equals {
        key   = "aws:ResourceTag/${var.ec2_backup_tags.key}"
        value = var.ec2_backup_tags.value
      }
    }
  }
}

# Backup Selection for RDS Instances
resource "aws_backup_selection" "rds" {
  count = var.backup_rds_instances ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.naming_prefix}-rds-backup"
  plan_id      = aws_backup_plan.main.id

  resources = var.rds_instance_arns

  dynamic "condition" {
    for_each = length(var.rds_backup_tags) > 0 ? [1] : []
    content {
      string_equals {
        key   = "aws:ResourceTag/${var.rds_backup_tags.key}"
        value = var.rds_backup_tags.value
      }
    }
  }
}

# Backup Selection for EBS Volumes
resource "aws_backup_selection" "ebs" {
  count = var.backup_ebs_volumes ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.naming_prefix}-ebs-backup"
  plan_id      = aws_backup_plan.main.id

  resources = var.ebs_volume_arns

  dynamic "condition" {
    for_each = length(var.ebs_backup_tags) > 0 ? [1] : []
    content {
      string_equals {
        key   = "aws:ResourceTag/${var.ebs_backup_tags.key}"
        value = var.ebs_backup_tags.value
      }
    }
  }
}

# Backup Selection for DynamoDB Tables
resource "aws_backup_selection" "dynamodb" {
  count = var.backup_dynamodb_tables ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.naming_prefix}-dynamodb-backup"
  plan_id      = aws_backup_plan.main.id

  resources = var.dynamodb_table_arns

  dynamic "condition" {
    for_each = length(var.dynamodb_backup_tags) > 0 ? [1] : []
    content {
      string_equals {
        key   = "aws:ResourceTag/${var.dynamodb_backup_tags.key}"
        value = var.dynamodb_backup_tags.value
      }
    }
  }
}

# Backup Selection for EFS File Systems
resource "aws_backup_selection" "efs" {
  count = var.backup_efs_filesystems ? 1 : 0

  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.naming_prefix}-efs-backup"
  plan_id      = aws_backup_plan.main.id

  resources = var.efs_filesystem_arns

  dynamic "condition" {
    for_each = length(var.efs_backup_tags) > 0 ? [1] : []
    content {
      string_equals {
        key   = "aws:ResourceTag/${var.efs_backup_tags.key}"
        value = var.efs_backup_tags.value
      }
    }
  }
}

# CloudWatch Event Rule for Backup Job State Changes
resource "aws_cloudwatch_event_rule" "backup_job_events" {
  count = var.enable_backup_notifications ? 1 : 0

  name        = "${var.naming_prefix}-backup-events"
  description = "Capture backup job state changes"

  event_pattern = jsonencode({
    source      = ["aws.backup"]
    detail-type = ["Backup Job State Change"]
    detail = {
      state = ["FAILED", "EXPIRED", "PARTIAL"]
    }
  })

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-backup-events"
  })
}

# SNS Topic for Backup Notifications
resource "aws_sns_topic" "backup_notifications" {
  count = var.enable_backup_notifications ? 1 : 0

  name = "${var.naming_prefix}-backup-notifications"

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-backup-notifications"
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "backup_notifications" {
  count = var.enable_backup_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.backup_job_events[0].name
  target_id = "BackupNotificationTarget"
  arn       = aws_sns_topic.backup_notifications[0].arn
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "backup_notifications" {
  count = var.enable_backup_notifications ? 1 : 0

  arn = aws_sns_topic.backup_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.backup_notifications[0].arn
      }
    ]
  })
}
