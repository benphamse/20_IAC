# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name    = var.domain_name
  comment = "Hosted zone for ${var.domain_name}"

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-hosted-zone"
  })
}

# Route53 Private Hosted Zone
resource "aws_route53_zone" "private" {
  count = var.create_private_zone ? 1 : 0

  name    = var.private_domain_name
  comment = "Private hosted zone for ${var.private_domain_name}"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-private-hosted-zone"
  })
}

# A Record for ALB
resource "aws_route53_record" "alb" {
  count = var.alb_dns_name != null && var.create_hosted_zone ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# CNAME Record for www
resource "aws_route53_record" "www" {
  count = var.create_www_record && var.create_hosted_zone ? 1 : 0

  zone_id = aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.domain_name]
}

# Health Check
resource "aws_route53_health_check" "main" {
  count = var.enable_health_check ? 1 : 0

  fqdn                            = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  port                            = var.health_check_port
  type                            = var.health_check_type
  resource_path                   = var.health_check_path
  failure_threshold               = var.health_check_failure_threshold
  request_interval                = var.health_check_request_interval
  cloudwatch_alarm_region         = var.aws_region
  cloudwatch_alarm_name           = "${var.naming_prefix}-health-check-alarm"
  insufficient_data_health_status = "Failure"

  tags = merge(var.tags, {
    Name = "${var.naming_prefix}-health-check"
  })
}

# Private DNS Records
resource "aws_route53_record" "private" {
  for_each = var.private_records

  zone_id = var.create_private_zone ? aws_route53_zone.private[0].zone_id : var.existing_private_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}
