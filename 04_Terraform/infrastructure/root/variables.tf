# ============================================================================
# SHARED VARIABLES CONFIGURATION
# ============================================================================
# All variable definitions shared across environments.
# Values are set in each environment's terraform.tfvars file.
# ============================================================================

# ============================================================================
# COMMON VARIABLES
# ============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing and resource tracking"
  type        = string
  default     = "engineering"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# NETWORK VARIABLES
# ============================================================================

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
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# ============================================================================
# COMPUTE VARIABLES
# ============================================================================

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = null
}

variable "enable_auto_scaling" {
  description = "Enable Auto Scaling Group"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

# ============================================================================
# SECURITY VARIABLES
# ============================================================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access web services"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh_access" {
  description = "Enable SSH access to instances"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ============================================================================
# LOAD BALANCER VARIABLES
# ============================================================================

variable "enable_load_balancer" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = false
}

# ============================================================================
# STORAGE VARIABLES
# ============================================================================

variable "enable_storage_module" {
  description = "Enable S3 storage module"
  type        = bool
  default     = true
}

# ============================================================================
# MONITORING VARIABLES
# ============================================================================

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

# ============================================================================
# CACHING VARIABLES
# ============================================================================

variable "enable_caching" {
  description = "Enable ElastiCache Redis/Memcached"
  type        = bool
  default     = false
}

# ============================================================================
# DNS VARIABLES
# ============================================================================

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

# ============================================================================
# CONTAINER VARIABLES (ECS)
# ============================================================================

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

# ============================================================================
# CI/CD VARIABLES
# ============================================================================

variable "enable_cicd" {
  description = "Enable CI/CD pipeline (CodePipeline, CodeBuild, CodeDeploy)"
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

# IAM Role ARNs for CI/CD
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

# ============================================================================
# SERVERLESS VARIABLES (Lambda + API Gateway)
# ============================================================================

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

# ============================================================================
# BACKUP VARIABLES
# ============================================================================

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

# ============================================================================
# GOVERNANCE VARIABLES (Config, CloudTrail, Security Hub, GuardDuty)
# ============================================================================

variable "enable_governance" {
  description = "Enable governance (Config, CloudTrail, Security Hub, GuardDuty)"
  type        = bool
  default     = false
}
