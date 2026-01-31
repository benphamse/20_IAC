variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access web services"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh_access" {
  description = "Enable SSH access to web servers"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed SSH access"
  type        = list(string)
  default     = []
}
