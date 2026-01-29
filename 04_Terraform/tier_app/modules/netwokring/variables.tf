variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnet_count" {
  type        = number
  description = "The number of public subnets"
}

variable "private_subnet_count" {
  type        = number
  description = "The number of private subnets"
}

variable "bastion_host_allowed_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks allowed to access the bastion host"
}

variable "database_subnet_count" {
  type        = bool
  default     = false
  description = "Whether to create a database subnet group"
}