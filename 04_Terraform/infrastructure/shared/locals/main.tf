# Common local values used across the infrastructure
locals {
  # Naming convention: {project}-{environment}-{resource}
  naming_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to all resources
  common_tags = merge(var.additional_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
    CostCenter  = var.cost_center
  })

  # Network configuration
  vpc_cidr = var.vpc_cidr

  # Availability zones for the region
  availability_zones = data.aws_availability_zones.available.names

  # Public and private subnet CIDRs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
