locals {
  instance_type = "t2.micro"
  location      = "ap-southeast-1"
  environment   = "production"
  vpc_cidr      = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

module "networking" {
  source                           = "../modules/netwokring"
  vpc_cidr_block                   = local.vpc_cidr
  public_subnet_count              = 2
  private_subnet_count             = 2
  database_subnet_count            = true
  bastion_host_allowed_cidr_blocks = var.bastion_host_allowed_cidr_blocks
}


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

module "database" {
  source                 = "../modules/database"
  db_instance_class      = "db.t3.micro"
  db_engine_version      = "8.0.40"
  db_skip_final_snapshot = true # Set to true for Free Tier compatibility, as it avoids the final snapshot cost.
  db_subnet_group_name   = module.networking.rds_subnet_group_name[0]
  rds_security_group_id  = module.networking.rds_security_group_id
  db_name                = "three_tier_db"
  db_identifier          = "three-tier-db"
  db_username            = "admin"
  db_password            = "password"
  store_type             = "gp3" # Use General Purpose SSD storage, which is Free Tier eligible.
  multi_az               = false # Ensure Multi-AZ is disabled for Free Tier compatibility.
  deletion_protection    = false # Ensure deletion protection is disabled for Free Tier compatibility.
  db_allocated_storage   = 10    # Stay within the 20 GB storage limit.

  depends_on = [module.networking]
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