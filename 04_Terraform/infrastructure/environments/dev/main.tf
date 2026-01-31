# Security module
module "security" {
  source = "../../modules/security"

  vpc_id              = module.networking.vpc_id
  naming_prefix       = local.naming_prefix
  tags                = local.common_tags
  allowed_cidr_blocks = var.allowed_cidr_blocks
  enable_ssh_access   = var.enable_ssh_access
  ssh_cidr_blocks     = var.ssh_cidr_blocks
}

# Monitoring module
module "monitoring" {
  source = "../../modules/monitoring"

  naming_prefix      = local.naming_prefix
  tags               = local.common_tags
  aws_region         = var.aws_region
  log_retention_days = 7 # Short retention for dev

  # CloudWatch Alarms
  enable_cpu_alarm = true
  cpu_threshold    = 80
  asg_name         = var.enable_auto_scaling ? module.compute.autoscaling_group_id : null

  # Dashboard metrics
  dashboard_metrics = [
    ["AWS/EC2", "CPUUtilization"],
    ["AWS/ApplicationELB", "RequestCount"],
    ["AWS/ApplicationELB", "TargetResponseTime"]
  ]
}

# Caching module (Redis/ElastiCache)
module "caching" {
  count  = var.enable_caching ? 1 : 0
  source = "../../modules/caching"

  naming_prefix      = local.naming_prefix
  tags               = local.common_tags
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.database_security_group_id]

  # Cache configuration
  engine             = "redis"
  node_type          = "cache.t3.micro" # Small for dev
  num_cache_clusters = 1
  engine_version     = "7.0"
  port               = 6379

  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # Simplified for dev

  # Backup
  snapshot_retention_limit = 1
  maintenance_window       = "sun:03:00-sun:04:00"
}

# Container module (ECS)
module "container" {
  count  = var.enable_containers ? 1 : 0
  source = "../../modules/container"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags
  aws_region    = var.aws_region

  # ECS Configuration
  capacity_providers        = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider = "FARGATE"
  enable_container_insights = true

  # Task Definition
  container_name  = "${var.project_name}-app"
  container_image = var.container_image
  container_port  = 3000
  task_cpu        = "256"
  task_memory     = "512"

  # Networking
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.web_security_group_id]
  assign_public_ip   = false

  # Service Configuration
  desired_count = 1
  launch_type   = "FARGATE"

  # Load Balancer Integration
  target_group_arn = var.enable_load_balancer ? module.load_balancing[0].target_group_arn : null

  # Auto Scaling
  enable_autoscaling       = false # Disabled for dev
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 3
  autoscaling_target_cpu   = 70

  # Logging
  log_retention_days = 7
}

# CI/CD module
module "cicd" {
  count  = var.enable_cicd ? 1 : 0
  source = "../../modules/cicd"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags

  # Source Configuration
  create_codecommit_repo = var.create_codecommit_repo
  source_provider        = var.source_provider
  source_branch          = var.source_branch

  # GitHub Configuration (if using GitHub)
  github_owner = var.github_owner
  github_repo  = var.github_repo
  github_token = var.github_token

  # Build Configuration
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  privileged_mode    = true # For Docker builds

  # Service Roles (you'll need to create these)
  codebuild_service_role_arn    = var.codebuild_service_role_arn
  codedeploy_service_role_arn   = var.codedeploy_service_role_arn
  codepipeline_service_role_arn = var.codepipeline_service_role_arn

  # Deploy Configuration
  enable_codedeploy = var.enable_containers
  compute_platform  = var.enable_containers ? "ECS" : "Server"
  ecs_cluster_name  = var.enable_containers ? module.container[0].cluster_name : null
  ecs_service_name  = var.enable_containers ? module.container[0].service_name : null

  # Artifacts
  force_destroy_artifacts = true # Only for dev
}

# Serverless module (Lambda + API Gateway)
module "serverless" {
  count  = var.enable_serverless ? 1 : 0
  source = "../../modules/serverless"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags

  # Lambda Configuration
  lambda_execution_role_arn = var.lambda_execution_role_arn
  lambda_handler            = var.lambda_handler
  lambda_runtime            = var.lambda_runtime
  lambda_timeout            = 30
  lambda_memory_size        = 128

  # VPC Configuration (optional for dev)
  subnet_ids         = var.lambda_in_vpc ? module.networking.private_subnet_ids : null
  security_group_ids = var.lambda_in_vpc ? [module.security.web_security_group_id] : null

  # API Gateway Configuration
  create_api_gateway = var.create_api_gateway
  api_path_part      = var.api_path_part
  api_http_method    = "GET"
  api_authorization  = "NONE"
  api_stage_name     = var.environment
  enable_api_logging = true

  # EventBridge Scheduling (optional)
  lambda_schedule_expression = var.lambda_schedule_expression

  # Monitoring
  log_retention_days  = 7     # Short retention for dev
  enable_xray_tracing = false # Simplified for dev

  # Environment Variables
  environment_variables = {
    ENVIRONMENT = var.environment
    LOG_LEVEL   = "INFO"
  }
}

# Backup module
module "backup" {
  count  = var.enable_backup ? 1 : 0
  source = "../../modules/backup"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags

  # Backup Plan Configuration
  daily_backup_schedule   = "cron(0 6 ? * * *)" # 6 AM daily
  cold_storage_after_days = 30
  delete_after_days       = 90 # Shorter for dev

  # Weekly and Monthly backups (disabled for dev)
  enable_weekly_backup  = false
  enable_monthly_backup = false

  # Resource Selection
  backup_ec2_instances = var.backup_ec2_instances
  ec2_instance_arns    = var.enable_auto_scaling ? [module.compute.autoscaling_group_arn] : []

  backup_ebs_volumes = var.backup_ebs_volumes
  ebs_volume_arns    = [] # Will be populated based on actual volumes

  backup_rds_instances = false # No RDS in basic dev setup
  rds_instance_arns    = []

  # Notifications
  enable_backup_notifications = var.enable_backup_notifications
}

# Governance module (AWS Config, CloudTrail, Security Hub, GuardDuty)
module "governance" {
  count  = var.enable_governance ? 1 : 0
  source = "../../modules/governance"

  naming_prefix = local.naming_prefix
  tags          = local.common_tags

  # AWS Config Configuration
  enable_config                   = true
  config_record_all_resources     = true
  config_include_global_resources = true
  config_delivery_frequency       = "TwentyFour_Hours"
  config_bucket_force_destroy     = true # Only for dev

  # Config Rules
  enable_s3_compliance_rules  = true
  enable_ec2_compliance_rules = true
  enable_iam_compliance_rules = true

  # IAM Password Policy
  password_require_uppercase = true
  password_require_lowercase = true
  password_require_symbols   = true
  password_require_numbers   = true
  password_min_length        = 12 # Relaxed for dev
  password_reuse_prevention  = 12
  password_max_age           = 90

  # CloudTrail Configuration
  enable_cloudtrail               = true
  cloudtrail_multi_region         = false # Single region for dev
  cloudtrail_bucket_force_destroy = true  # Only for dev

  # GuardDuty Configuration
  enable_guardduty                       = true
  guardduty_enable_s3_logs               = true
  guardduty_enable_kubernetes_audit_logs = false # No K8s in basic setup
  guardduty_enable_malware_protection    = true

  # Security Hub Configuration
  enable_security_hub                   = true
  security_hub_enable_default_standards = true
  enable_aws_foundational_standard      = true
  enable_cis_standard                   = true
  enable_pci_dss_standard               = false # Not needed for dev
}
