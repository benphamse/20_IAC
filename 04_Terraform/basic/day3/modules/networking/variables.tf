variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_1_cidr" {
  default     = "10.0.1.0/24"
  type        = string
  description = "CIDR block for the first public subnet"
}

variable "public_subnet_2_cidr" {
  default     = "10.0.2.0/24"
  type        = string
  description = "CIDR block for the second public subnet"
}

variable "availability_zone_1" {
  default     = "us-east-1a"
  type        = string
  description = "First availability zone"
}

variable "availability_zone_2" {
  default     = "us-east-1b"
  type        = string
  description = "Second availability zone"
}
