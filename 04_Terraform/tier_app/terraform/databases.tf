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
  db_allocated_storage   = 20    # Minimum storage for gp3 with MySQL is 20 GB.

  depends_on = [module.networking]
}
