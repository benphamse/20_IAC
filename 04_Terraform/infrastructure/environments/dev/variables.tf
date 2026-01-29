# Common variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-enterprise"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

# Compute variables
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

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

# Security variables
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access web services"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh_access" {
  description = "Enable SSH access"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Load Balancer variables
variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = false
}

# Storage variables
variable "enable_storage_module" {
  description = "Enable S3 storage module"
  type        = bool
  default     = true
}

# Monitoring variables
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring module"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# Caching variables
variable "enable_caching" {
  description = "Enable ElastiCache Redis/Memcached"
  type        = bool
  default     = false
}

# DNS variables
variable "enable_dns" {
  description = "Enable Route53 DNS management"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone"
  type        = string
  default     = "example.com"
}

variable "create_hosted_zone" {
  description = "Create Route53 hosted zone"
  type        = bool
  default     = false
}

# Container variables
variable "enable_containers" {
  description = "Enable ECS container services"
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Docker container image"
  type        = string
  default     = "nginx:latest"
}

# CI/CD variables
variable "enable_cicd" {
  description = "Enable CI/CD pipeline"
  type        = bool
  default     = false
}

variable "create_codecommit_repo" {
  description = "Create CodeCommit repository"
  type        = bool
  default     = true
}

variable "source_provider" {
  description = "Source provider (CodeCommit or GitHub)"
  type        = string
  default     = "CodeCommit"
  validation {
    condition     = contains(["CodeCommit", "GitHub"], var.source_provider)
    error_message = "Source provider must be either CodeCommit or GitHub."
  }
}

variable "source_branch" {
  description = "Source branch name"
  type        = string
  default     = "main"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = null
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = null
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  default     = null
  sensitive   = true
}

# IAM Role ARNs for CI/CD (you'll need to create these)
variable "codebuild_service_role_arn" {
  description = "CodeBuild service role ARN"
  type        = string
  default     = null
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy service role ARN"
  type        = string
  default     = null
}

variable "codepipeline_service_role_arn" {
  description = "CodePipeline service role ARN"
  type        = string
  default     = null
}

# Serverless variables
variable "enable_serverless" {
  description = "Enable serverless (Lambda + API Gateway)"
  type        = bool
  default     = false
}

variable "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  type        = string
  default     = null
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "lambda_in_vpc" {
  description = "Deploy Lambda in VPC"
  type        = bool
  default     = false
}

variable "create_api_gateway" {
  description = "Create API Gateway for Lambda"
  type        = bool
  default     = true
}

variable "api_path_part" {
  description = "API Gateway path part"
  type        = string
  default     = "api"
}

variable "lambda_schedule_expression" {
  description = "EventBridge schedule expression for Lambda"
  type        = string
  default     = null
}

# Backup variables
variable "enable_backup" {
  description = "Enable AWS Backup"
  type        = bool
  default     = false
}

variable "backup_ec2_instances" {
  description = "Enable backup for EC2 instances"
  type        = bool
  default     = false
}

variable "backup_ebs_volumes" {
  description = "Enable backup for EBS volumes"
  type        = bool
  default     = false
}

variable "enable_backup_notifications" {
  description = "Enable backup notifications"
  type        = bool
  default     = false
}

# Governance variables
variable "enable_governance" {
  description = "Enable governance (Config, CloudTrail, Security Hub, GuardDuty)"
  type        = bool
  default     = false
}
