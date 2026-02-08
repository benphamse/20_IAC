/**
  <Block type> <Block Label> <Block Label> {
    # Block body
    <Identifier> = <Expression> # Argument
  }
*/
module "networking" {
  source = "../modules/networking"

  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_1_cidr = var.public_subnet_1_cidr
  availability_zone_1  = var.availability_zone_1
  common_tags          = local.common_tags
}

# Security Module
module "security" {
  source = "../modules/security"

  vpc_id              = module.networking.vpc_id
  security_group_name = local.security_group_name
  common_tags         = local.common_tags
}

# Compute Module
module "compute" {
  source = "../modules/compute"

  ami_value         = var.ami_value
  instance_type     = var.instance_type
  subnet_1_id       = module.networking.public_subnet_1_id
  security_group_id = module.security.security_group_id
  common_tags       = local.common_tags

  depends_on = [module.networking, module.security]
}
