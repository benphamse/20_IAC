variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Lambda Configuration
variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = null
}

variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
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

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "dlq_target_arn" {
  description = "ARN of the dead letter queue"
  type        = string
  default     = null
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "cloudwatch_kms_key_id" {
  description = "KMS key ID for CloudWatch logs encryption"
  type        = string
  default     = null
}

# VPC Configuration (optional)
variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = null
}

# API Gateway Configuration
variable "create_api_gateway" {
  description = "Create API Gateway"
  type        = bool
  default     = true
}

variable "api_gateway_endpoint_type" {
  description = "API Gateway endpoint type"
  type        = string
  default     = "REGIONAL"
}

variable "api_path_part" {
  description = "API Gateway resource path part"
  type        = string
  default     = "api"
}

variable "api_http_method" {
  description = "API Gateway method"
  type        = string
  default     = "ANY"
}

variable "api_authorization" {
  description = "API Gateway authorization type"
  type        = string
  default     = "NONE"
}

variable "api_request_parameters" {
  description = "API Gateway request parameters"
  type        = map(bool)
  default     = {}
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "dev"
}

variable "enable_api_logging" {
  description = "Enable API Gateway logging"
  type        = bool
  default     = true
}

# EventBridge Scheduling
variable "lambda_schedule_expression" {
  description = "Schedule expression for Lambda (e.g., rate(5 minutes))"
  type        = string
  default     = null
}
