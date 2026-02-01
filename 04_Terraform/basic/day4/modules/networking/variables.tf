variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"            # Default CIDR block for the VPC
  type        = string                   # The type of the variable, in this case a string
  description = "CIDR block for the VPC" # Description of what this variable represents

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.vpc_cidr_block))
    error_message = "Invalid CIDR block format. Please use a valid CIDR notation (e.g.,)"
  }

  validation {
    condition     = length(split("/", var.vpc_cidr_block)) == 2
    error_message = "CIDR block must be in the format x.x.x.x/y"
  }
}

variable "public_subnet_1_cidr" {
  default     = "10.0.1.0/24"                            # Default CIDR block for the first public subnet
  type        = string                                   # The type of the variable, in this case a string
  description = "CIDR block for the first public subnet" # Description of what this variable represents

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.public_subnet_1_cidr))
    error_message = "Invalid CIDR block format. Please use a valid CIDR notation (e.g.,)"
  }

  validation {
    condition     = length(split("/", var.public_subnet_1_cidr)) == 2
    error_message = "CIDR block must be in the format x.x.x.x/y"
  }
}

variable "availability_zone_1" {
  default     = "us-east-1a"                                    # Default availability zone for the first public subnet
  type        = string                                          # The type of the variable, in this case a string
  description = "Availability zone for the first public subnet" # Description of what this variable represents
}

