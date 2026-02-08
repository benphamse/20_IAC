resource "aws_db_instance" "database" {
  allocated_storage      = var.db_allocated_storage
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = var.db_skip_final_snapshot
  db_subnet_group_name   = var.db_subnet_group_name
  identifier             = var.db_identifier
  vpc_security_group_ids = [var.rds_security_group_id]

  # General Purpose SSD "gp3"   #Use General Purpose SSD storage. "gp3" is newer and also free tier eligible.
  storage_type        = var.store_type
  multi_az            = var.multi_az #CRITICAL: Ensure Multi-AZ is disabled for the Free Tier.
  deletion_protection = var.deletion_protection

  tags = {
    Name = "database"
  }
}