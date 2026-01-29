variable "vpc_id" {
  type        = string
  description = "ID of the VPC where load balancer will be created"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group for the load balancer"
}

variable "subnet_1_id" {
  type        = string
  description = "ID of the first subnet for the load balancer"
}

variable "subnet_2_id" {
  type        = string
  description = "ID of the second subnet for the load balancer"
}

variable "web_server1_id" {
  type        = string
  description = "ID of the first web server instance"
}

variable "web_server2_id" {
  type        = string
  description = "ID of the second web server instance"
}

variable "lb_name" {
  type        = string
  default     = "web-application-lb"
  description = "Name of the load balancer"
}
