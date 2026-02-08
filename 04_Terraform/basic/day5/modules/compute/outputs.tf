output "web_server1_id" {
  description = "ID of the first web server instance"
  value       = aws_instance.web_server1.id
}

output "web_server1_public_ip" {
  description = "Public IP address of the first web server"
  value       = aws_instance.web_server1.public_ip
}

