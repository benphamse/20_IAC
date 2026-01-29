# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.naming_prefix}-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-cache-subnet-group"
  })
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  count = var.parameter_group_name == null ? 1 : 0

  family = var.engine == "redis" ? "redis${var.engine_version}" : "memcached${var.engine_version}"
  name   = "${var.naming_prefix}-cache-params"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-cache-parameter-group"
  })
}

# ElastiCache Replication Group (Redis)
resource "aws_elasticache_replication_group" "redis" {
  count = var.engine == "redis" ? 1 : 0

  replication_group_id = "${var.naming_prefix}-redis"
  description          = "Redis cluster for ${var.naming_prefix}"

  # Node configuration
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = var.port
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.main[0].name

  # Network configuration
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  # Engine configuration
  engine_version = var.engine_version

  # Backup configuration
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  # Security
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.auth_token

  # Multi-AZ
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-redis-cluster"
  })
}

# ElastiCache Cluster (Memcached)
resource "aws_elasticache_cluster" "memcached" {
  count = var.engine == "memcached" ? 1 : 0

  cluster_id           = "${var.naming_prefix}-memcached"
  engine               = "memcached"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_clusters
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_elasticache_parameter_group.main[0].name
  port                 = var.port
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = var.security_group_ids
  engine_version       = var.engine_version
  maintenance_window   = var.maintenance_window

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-memcached-cluster"
  })
}
