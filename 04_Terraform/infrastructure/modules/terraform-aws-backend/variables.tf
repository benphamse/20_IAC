# Variables for backend module

variable "naming_prefix" {
  description = "Prefix for naming resources"
  type        = string
  validation {
    condition     = length(var.naming_prefix) > 0 && length(var.naming_prefix) <= 50
    error_message = "Naming prefix must be between 1 and 50 characters."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "state_retention_days" {
  description = "Number of days to retain old state file versions"
  type        = number
  default     = 30
  validation {
    condition     = var.state_retention_days >= 1 && var.state_retention_days <= 365
    error_message = "State retention days must be between 1 and 365."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable point in time recovery for DynamoDB table"
  type        = bool
  default     = true
}

variable "create_backend_policy" {
  description = "Whether to create IAM policy for backend access"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring for backend"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch log retention period."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}
