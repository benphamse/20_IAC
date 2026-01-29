# Variables for backend setup

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-infrastructure"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "create_backend_policy" {
  description = "Whether to create IAM policy for backend access"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring for backend"
  type        = bool
  default     = false
}
