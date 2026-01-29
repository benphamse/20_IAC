# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  availability_zone_1  = "ap-southeast-1a"
  availability_zone_2  = "ap-southeast-1b"
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id              = module.networking.vpc_id
  security_group_name = "${var.project_name}-${var.environment}-sg"
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  ami_value         = var.ami_value
  instance_type     = var.instance_type
  subnet_1_id       = module.networking.public_subnet_1_id
  subnet_2_id       = module.networking.public_subnet_2_id
  security_group_id = module.security.security_group_id

  depends_on = [module.networking, module.security]
}

# Load Balancing Module
module "load_balancing" {
  source = "./modules/load-balancing"

  vpc_id            = module.networking.vpc_id
  security_group_id = module.security.security_group_id
  subnet_1_id       = module.networking.public_subnet_1_id
  subnet_2_id       = module.networking.public_subnet_2_id
  web_server1_id    = module.compute.web_server1_id
  web_server2_id    = module.compute.web_server2_id
  lb_name           = "${var.project_name}-${var.environment}-alb"

  depends_on = [module.compute]
}
