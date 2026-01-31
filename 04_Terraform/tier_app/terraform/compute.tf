module "compute" {
  source                     = "../modules/compute"
  instance_type              = local.instance_type
  ssh_key                    = "test"
  key_name                   = "test"
  public_subnets             = module.networking.public_subnets
  private_subnets            = module.networking.private_subnets
  alb_target_group_arn       = module.load_balancer.lb_target_group_arn
  bastion_security_group_id  = module.networking.bastion_host_security_group.id
  frontend_security_group_id = module.networking.application_server_security_group_id
  backend_security_group_id  = module.networking.backend_server_security_group_id

  depends_on = [module.networking, module.load_balancer]
}
