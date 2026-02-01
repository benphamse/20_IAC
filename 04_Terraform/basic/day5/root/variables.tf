# Core variables that will be set by tfvars files
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.vpc_cidr_block))
    error_message = "Invalid CIDR block format. Please use a valid CIDR notation (e.g., 10.0.0.0/16)"
  }
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR block for the first public subnet"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.public_subnet_1_cidr))
    error_message = "Invalid CIDR block format. Please use a valid CIDR notation (e.g., 10.0.1.0/24)"
  }
}

variable "availability_zone_1" {
  type        = string
  description = "Availability zone for the first public subnet"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the web servers"

  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium", "t2.large",
      "t3.micro", "t3.small", "t3.medium", "t3.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name can only contain alphanumeric characters and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "ami_value" {
  type        = string
  description = "AMI ID for the web servers"
  default     = "ami-0b8607d2721c94a77"

  validation {
    condition     = can(regex("^ami-[a-z0-9]+$", var.ami_value))
    error_message = "AMI ID must start with 'ami-' followed by alphanumeric characters."
  }
}

variable "owner" {
  type        = string
  description = "Owner of the resources"
  default     = "Ben Pham Dev"
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed monitoring for instances"
  default     = false
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

# Locals for computed values
locals {
  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }

  # Computed values
  security_group_name = "${var.project_name}-${var.environment}-sg"

  # Environment-specific computed values
  is_production = var.environment == "prod"

  # Instance settings based on environment
  detailed_monitoring = var.environment == "prod" ? true : var.enable_monitoring
}
