resource "aws_ssm_parameter" "ami" {
  name        = "/production/ami"
  type        = "String"
  value       = data.aws_ami.amazon_linux.id # Use dynamically fetched AMI ID
  description = "Production AMI ID for Amazon Linux 2"

  tags = {
    Name        = "production-ami"
    Environment = "production"
  }
}
