variable "alb_security_group" {
  type        = string
  description = "The security group for the ALB"
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets for the ALB"
}

variable "frontend_sg" {
  type        = string
  description = "The security group for the application"
}

variable "alb_target_group_protocol" {
  type        = string
  description = "The protocol for the ALB target group"
}

variable "alb_target_group_port" {
  type        = number
  description = "The port for the ALB target group"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for the ALB"
}