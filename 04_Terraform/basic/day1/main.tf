provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

# Example resource - you can replace this with your actual infrastructure
resource "aws_instance" "example" {
  ami           = "ami-0b8607d2721c94a77" # Amazon Linux 2 AMI (update as needed)
  instance_type = "t2.micro"

  tags = {
    Name        = "day1-example-instance"
    Environment = "dev"
  }
}

# Output example
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}