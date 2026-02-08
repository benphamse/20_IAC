variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Instance configuration
variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

variable "detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "encrypt_volumes" {
  description = "Encrypt EBS volumes"
  type        = bool
  default     = true
}

variable "associate_public_ip_address" {
  description = "Associate public IP address with instances"
  type        = bool
  default     = false
}

# Auto Scaling configuration
variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "target_group_arns" {
  description = "List of target group ARNs for ASG"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Type of health check for ASG"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period for ASG"
  type        = number
  default     = 300
}

variable "instance_count" {
  description = "Number of instances to create (when not using ASG)"
  type        = number
  default     = 1
}
