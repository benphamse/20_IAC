module "networking" {
  source = "./modules/networking"

  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_1_cidr = var.public_subnet_1_cidr
  availability_zone_1  = var.availability_zone_1
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
  security_group_id = module.security.security_group_id

  depends_on = [module.networking, module.security]
}

resource "timeouts_example" "example" {
  /* ... */

  timeouts {
    create = "60m"
  }
}
