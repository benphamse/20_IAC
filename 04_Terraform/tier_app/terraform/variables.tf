variable "bastion_host_allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the bastion host"
  default     = ["0.0.0.0/0"]
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}
