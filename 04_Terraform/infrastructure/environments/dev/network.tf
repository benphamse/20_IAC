# Networking module
module "networking" {
  source = "../../modules/networking"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = local.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  naming_prefix        = local.naming_prefix
  tags                 = local.common_tags
}

# Load Balancing module (optional for dev)
module "load_balancing" {
  count  = var.enable_load_balancer ? 1 : 0
  source = "../../modules/load-balancing"

  naming_prefix      = local.naming_prefix
  tags               = local.common_tags
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.public_subnet_ids
  security_group_ids = [module.security.alb_security_group_id]

  # ALB Configuration
  internal                   = false
  enable_deletion_protection = false # Dev environment

  # Target Group Configuration
  target_port     = 80
  target_protocol = "HTTP"

  # Health Check Configuration
  health_check_path                = "/"
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_timeout             = 5
  health_check_interval            = 30

  # Listener Configuration
  listener_port     = 80
  listener_protocol = "HTTP"
}

# DNS module (Route53)
module "dns" {
  count  = var.enable_dns ? 1 : 0
  source = "../../modules/dns"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags
  aws_region    = var.aws_region

  # Domain configuration
  domain_name        = var.domain_name
  create_hosted_zone = var.create_hosted_zone

  # ALB integration
  alb_dns_name = var.enable_load_balancer ? module.load_balancing[0].alb_dns_name : null
  alb_zone_id  = var.enable_load_balancer ? module.load_balancing[0].alb_zone_id : null

  # Private zone
  create_private_zone = true
  private_domain_name = "${var.environment}.internal"
  vpc_id              = module.networking.vpc_id

  # Health checks
  enable_health_check = var.enable_load_balancer
  health_check_port   = 80
  health_check_path   = "/health"
}