variable "ami_value" {
  type        = string
  default     = "ami-0b8607d2721c94a77"
  description = "AMI ID for the web servers"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for the web servers"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Environment name (development, test, production)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_1_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the first public subnet"
}

variable "public_subnet_2_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for the second public subnet"
}

variable "project_name" {
  type        = string
  default     = "web-app"
  description = "Name of the project"
}

variable "owner" {
  type        = string
  default     = "DevOps Team"
  description = "Owner of the resources"
}
