output "database_endpoint" {
  value = aws_db_instance.database.endpoint
}

output "database_port" {
  value = aws_db_instance.database.port
}


output "database_username" {
  value = aws_db_instance.database.username
}