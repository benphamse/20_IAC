variable "db_allocated_storage" {
  type        = number
  description = "The allocated storage for the database"

  validation {
    condition     = var.db_allocated_storage <= 20
    error_message = "Allocated storage must be 20 GB or less for Free Tier compatibility."
  }
}

variable "multi_az" {
  default     = false
  type        = bool
  description = "Enable Multi-AZ for the database. Set to false for Free Tier compatibility."

  validation {
    condition     = !var.multi_az
    error_message = "Multi-AZ must be disabled for Free Tier compatibility."
  }
}

variable "deletion_protection" {
  default     = false
  type        = bool
  description = "Enable deletion protection for the database. Set to false for Free Tier compatibility."

  validation {
    condition     = !var.deletion_protection
    error_message = "Deletion protection must be disabled for Free Tier compatibility."
  }
}

variable "store_type" {
  default     = "gp3"
  type        = string
  description = "The storage type for the database. Use 'gp3' for Free Tier compatibility."

  validation {
    condition     = var.store_type == "gp3"
    error_message = "Storage type must be 'gp3' for Free Tier compatibility."
  }
}


variable "db_engine_version" {
  type        = string
  description = "The engine version for the database"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class for the database"
}

variable "db_name" {
  type        = string
  description = "The name for the database"
}

variable "db_username" {
  type        = string
  description = "The username for the database"
}

variable "db_password" {
  type        = string
  description = "The password for the database"
}

variable "rds_security_group_id" {
  type        = string
  description = "The security group ID for the database"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The subnet group name for the database"
}

variable "db_identifier" {
  type        = string
  description = "The identifier for the database"
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Whether to skip the final snapshot when the database is deleted"
}