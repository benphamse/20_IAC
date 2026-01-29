resource "aws_ssm_parameter" "ami" {
  name        = "/production/ami"
  type        = "String"
  value       = "ami-0b8607d2721c94a77" # Amazon Linux 2 AMI ID
  description = "Production AMI ID for Amazon Linux 2"

  tags = {
    Name        = "production-ami"
    Environment = "production"
  }
} 