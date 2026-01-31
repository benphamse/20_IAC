module "networking" {
  source                           = "../modules/netwokring"
  vpc_cidr_block                   = local.vpc_cidr
  public_subnet_count              = 2
  private_subnet_count             = 2
  database_subnet_count            = true
  bastion_host_allowed_cidr_blocks = var.bastion_host_allowed_cidr_blocks
}

module "load_balancer" {
  source                    = "../modules/load_balancing"
  frontend_sg               = module.networking.frontend_server_security_group_id
  public_subnets            = module.networking.public_subnets
  vpc_id                    = module.networking.vpc_id
  alb_security_group        = module.networking.load_balancer_security_group_id
  alb_target_group_port     = 80
  alb_target_group_protocol = "HTTP"

  depends_on = [module.networking]
}
