variable "vpc_id" {
  type        = string
  description = "ID of the VPC where security group will be created"
}

variable "security_group_name" {
  type        = string
  default     = "web-sg"
  description = "Name of the security group"
}
