# Compute module
module "compute" {
  source = "../../modules/compute"

  naming_prefix      = local.naming_prefix
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  key_name           = var.key_name
  security_group_ids = [module.security.web_security_group_id]
  subnet_ids         = module.networking.public_subnet_ids
  tags               = local.common_tags

  enable_auto_scaling = var.enable_auto_scaling
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  user_data = templatefile("${path.module}/user-data.sh", {
    environment = var.environment
  })
}
