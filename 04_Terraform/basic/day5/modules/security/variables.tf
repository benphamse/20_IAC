variable "vpc_id" {
  type        = string
  description = "ID of the VPC where security group will be created"
}

variable "security_group_name" {
  type        = string
  default     = "web-sg"
  description = "Name of the security group"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
  default     = {}
}
