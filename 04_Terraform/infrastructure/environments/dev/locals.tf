# Local values
locals {
  naming_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.additional_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  })

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}