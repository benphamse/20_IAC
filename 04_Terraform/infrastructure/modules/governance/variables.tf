variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# AWS Config Configuration
variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "config_record_all_resources" {
  description = "Record all supported resources"
  type        = bool
  default     = true
}

variable "config_include_global_resources" {
  description = "Include global resources in Config"
  type        = bool
  default     = true
}

variable "config_resource_types" {
  description = "List of resource types to record"
  type        = list(string)
  default     = []
}

variable "config_delivery_frequency" {
  description = "Frequency of Config snapshot deliveries"
  type        = string
  default     = "TwentyFour_Hours"
  validation {
    condition = contains([
      "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"
    ], var.config_delivery_frequency)
    error_message = "Config delivery frequency must be one of: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours."
  }
}

variable "config_s3_key_prefix" {
  description = "S3 key prefix for Config"
  type        = string
  default     = "config"
}

variable "config_bucket_force_destroy" {
  description = "Force destroy Config S3 bucket"
  type        = bool
  default     = false
}

variable "config_bucket_kms_key_id" {
  description = "KMS key ID for Config bucket encryption"
  type        = string
  default     = null
}

# Config Rules Configuration
variable "enable_s3_compliance_rules" {
  description = "Enable S3 compliance rules"
  type        = bool
  default     = true
}

variable "enable_ec2_compliance_rules" {
  description = "Enable EC2 compliance rules"
  type        = bool
  default     = true
}

variable "enable_iam_compliance_rules" {
  description = "Enable IAM compliance rules"
  type        = bool
  default     = true
}

# IAM Password Policy Configuration
variable "password_require_uppercase" {
  description = "Require uppercase characters in passwords"
  type        = bool
  default     = true
}

variable "password_require_lowercase" {
  description = "Require lowercase characters in passwords"
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Require symbols in passwords"
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Require numbers in passwords"
  type        = bool
  default     = true
}

variable "password_min_length" {
  description = "Minimum password length"
  type        = number
  default     = 14
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords to prevent reuse"
  type        = number
  default     = 24
}

variable "password_max_age" {
  description = "Maximum password age in days"
  type        = number
  default     = 90
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_multi_region" {
  description = "Enable multi-region trail"
  type        = bool
  default     = true
}

variable "cloudtrail_s3_key_prefix" {
  description = "S3 key prefix for CloudTrail"
  type        = string
  default     = "cloudtrail"
}

variable "cloudtrail_bucket_force_destroy" {
  description = "Force destroy CloudTrail S3 bucket"
  type        = bool
  default     = false
}

variable "cloudtrail_kms_key_id" {
  description = "KMS key ID for CloudTrail encryption"
  type        = string
  default     = null
}

variable "cloudtrail_exclude_management_events" {
  description = "Management event sources to exclude"
  type        = list(string)
  default     = []
}

variable "cloudtrail_s3_data_events" {
  description = "S3 buckets for data events"
  type        = list(string)
  default     = ["arn:aws:s3:::*/*"]
}

variable "cloudtrail_lambda_data_events" {
  description = "Lambda functions for data events"
  type        = list(string)
  default     = ["arn:aws:lambda:*:*:function:*"]
}

# GuardDuty Configuration
variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_enable_s3_logs" {
  description = "Enable S3 logs in GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_enable_kubernetes_audit_logs" {
  description = "Enable Kubernetes audit logs in GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_enable_malware_protection" {
  description = "Enable malware protection in GuardDuty"
  type        = bool
  default     = true
}

# Security Hub Configuration
variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "security_hub_enable_default_standards" {
  description = "Enable default standards in Security Hub"
  type        = bool
  default     = true
}

variable "enable_aws_foundational_standard" {
  description = "Enable AWS Foundational Security Standard"
  type        = bool
  default     = true
}

variable "enable_cis_standard" {
  description = "Enable CIS AWS Foundations Benchmark"
  type        = bool
  default     = true
}

variable "enable_pci_dss_standard" {
  description = "Enable PCI DSS standard"
  type        = bool
  default     = false
}
