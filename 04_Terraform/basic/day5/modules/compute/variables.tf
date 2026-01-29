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


variable "security_group_id" {
  type        = string
  description = "ID of the security group to attach to EC2 instances"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use for EC2 instances"
  default     = "terraform" # Replace with your actual key pair name
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
  default     = {}
}
