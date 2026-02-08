output "load_balancer_endpoint" {
  value = module.load_balancer.lb_endpoint
}

output "database_endpoint" {
  value = module.database.database_endpoint
}
