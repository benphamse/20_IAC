# AWS Config Configuration Recorder
resource "aws_config_configuration_recorder" "main" {
  count = var.enable_config ? 1 : 0

  name     = "${var.naming_prefix}-config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = var.config_record_all_resources
    include_global_resource_types = var.config_include_global_resources
    resource_types                = var.config_resource_types
  }

  depends_on = [aws_config_delivery_channel.main]
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "main" {
  count = var.enable_config ? 1 : 0

  name           = "${var.naming_prefix}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config[0].bucket
  s3_key_prefix  = var.config_s3_key_prefix

  snapshot_delivery_properties {
    delivery_frequency = var.config_delivery_frequency
  }
}

# S3 Bucket for AWS Config
resource "aws_s3_bucket" "config" {
  count = var.enable_config ? 1 : 0

  bucket        = "${var.naming_prefix}-config-bucket-${random_string.config_suffix[0].result}"
  force_destroy = var.config_bucket_force_destroy

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-config-bucket"
  })
}

resource "aws_s3_bucket_versioning" "config" {
  count = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "config" {
  count = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.config_bucket_kms_key_id
        sse_algorithm     = var.config_bucket_kms_key_id != null ? "aws:kms" : "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  count = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "config_suffix" {
  count = var.enable_config ? 1 : 0

  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Policy for AWS Config
resource "aws_s3_bucket_policy" "config" {
  count = var.enable_config ? 1 : 0

  bucket = aws_s3_bucket.config[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Role for AWS Config
resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0

  name = "${var.naming_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-config-role"
  })
}

# IAM Policy Attachment for AWS Config
resource "aws_iam_role_policy_attachment" "config" {
  count = var.enable_config ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}

# AWS Config Rules
resource "aws_config_config_rule" "s3_bucket_public_access_prohibited" {
  count = var.enable_config && var.enable_s3_compliance_rules ? 1 : 0

  name = "${var.naming_prefix}-s3-bucket-public-access-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_ACCESS_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-s3-public-access-rule"
  })
}

resource "aws_config_config_rule" "s3_bucket_ssl_requests_only" {
  count = var.enable_config && var.enable_s3_compliance_rules ? 1 : 0

  name = "${var.naming_prefix}-s3-bucket-ssl-requests-only"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-s3-ssl-only-rule"
  })
}

resource "aws_config_config_rule" "encrypted_volumes" {
  count = var.enable_config && var.enable_ec2_compliance_rules ? 1 : 0

  name = "${var.naming_prefix}-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-encrypted-volumes-rule"
  })
}

resource "aws_config_config_rule" "root_access_key_check" {
  count = var.enable_config && var.enable_iam_compliance_rules ? 1 : 0

  name = "${var.naming_prefix}-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-root-access-key-rule"
  })
}

resource "aws_config_config_rule" "iam_password_policy" {
  count = var.enable_config && var.enable_iam_compliance_rules ? 1 : 0

  name = "${var.naming_prefix}-iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters = var.password_require_uppercase
    RequireLowercaseCharacters = var.password_require_lowercase
    RequireSymbols             = var.password_require_symbols
    RequireNumbers             = var.password_require_numbers
    MinimumPasswordLength      = var.password_min_length
    PasswordReusePrevention    = var.password_reuse_prevention
    MaxPasswordAge             = var.password_max_age
  })

  depends_on = [aws_config_configuration_recorder.main]

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-iam-password-policy-rule"
  })
}

# CloudTrail for Governance
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name           = "${var.naming_prefix}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail[0].bucket
  s3_key_prefix  = var.cloudtrail_s3_key_prefix

  include_global_service_events = true
  is_multi_region_trail         = var.cloudtrail_multi_region
  enable_logging                = true

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = var.cloudtrail_exclude_management_events

    data_resource {
      type   = "AWS::S3::Object"
      values = var.cloudtrail_s3_data_events
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = var.cloudtrail_lambda_data_events
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-cloudtrail"
  })
}

# S3 Bucket for CloudTrail
resource "aws_s3_bucket" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket        = "${var.naming_prefix}-cloudtrail-bucket-${random_string.cloudtrail_suffix[0].result}"
  force_destroy = var.cloudtrail_bucket_force_destroy

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-cloudtrail-bucket"
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.cloudtrail_kms_key_id
        sse_algorithm     = var.cloudtrail_kms_key_id != null ? "aws:kms" : "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "cloudtrail_suffix" {
  count = var.enable_cloudtrail ? 1 : 0

  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"      = "bucket-owner-full-control"
            "AWS:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  # Optional: Configure data sources (deprecated parameter name, keeping for backward compatibility)
  datasources {
    s3_logs {
      enable = var.guardduty_enable_s3_logs
    }
    kubernetes {
      audit_logs {
        enable = var.guardduty_enable_kubernetes_audit_logs
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.guardduty_enable_malware_protection
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-guardduty-detector"
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Security Hub
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = var.security_hub_enable_default_standards
}

# Enable AWS Foundational Security Standard
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count = var.enable_security_hub && var.enable_aws_foundational_standard ? 1 : 0

  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/aws-foundational-security-standard/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]
}

# Enable CIS AWS Foundations Benchmark
resource "aws_securityhub_standards_subscription" "cis" {
  count = var.enable_security_hub && var.enable_cis_standard ? 1 : 0

  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.main]
}

# Enable PCI DSS
resource "aws_securityhub_standards_subscription" "pci_dss" {
  count = var.enable_security_hub && var.enable_pci_dss_standard ? 1 : 0

  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.main]
}
