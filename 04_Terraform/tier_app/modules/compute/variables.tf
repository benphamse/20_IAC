variable "instance_type" {
  type        = string
  description = "The instance type to use for the bastion host"
  default     = "t2.micro"
}

variable "bastion_security_group_id" {
  type        = string
  description = "The security group ID to use for the bastion host"
}

variable "ssh_key" {
  type        = string
  description = "The key name to use for the bastion host"
}

variable "key_name" {
  type        = string
  description = "The key name to use for the bastion host"
}

variable "tags" {
  type        = map(string)
  description = "The tags to use for the bastion host"

  default = {
    Name = "bastion"
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets to use for the bastion host"
}

variable "frontend_security_group_id" {
  type        = string
  description = "The security group ID to use for the frontend host"
}

variable "alb_target_group_arn" {
  type        = string
  description = "The ARN of the ALB target group"
}

variable "backend_security_group_id" {
  type        = string
  description = "The security group ID to use for the backend host"
}

variable "private_subnets" {
  type        = list(string)
  description = "The private subnets to use for the backend host"
}