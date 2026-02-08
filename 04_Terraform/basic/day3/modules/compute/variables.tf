variable "ami_value" {
  type        = string
  default     = "ami-0b8607d2721c94a77"
  description = "AMI ID for the web server"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for the web server"
}

variable "subnet_1_id" {
  type        = string
  description = "ID of the first subnet where EC2 instances will be created"
}

variable "subnet_2_id" {
  type        = string
  description = "ID of the second subnet where EC2 instances will be created"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group to attach to EC2 instances"
}
