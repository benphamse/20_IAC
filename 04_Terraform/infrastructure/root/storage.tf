# Storage module
module "storage" {
  source = "../../modules/storage"

  naming_prefix           = local.naming_prefix
  tags                    = local.common_tags
  versioning_enabled      = true
  force_destroy           = true # Only for dev environment
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
