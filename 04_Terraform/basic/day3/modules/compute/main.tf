resource "aws_instance" "web_server1" {
  ami                    = var.ami_value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_1_id
  user_data_base64       = base64encode(file("${path.module}/userdata.sh"))
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "web_server1"
  }
}

resource "aws_instance" "web_server2" {
  ami                    = var.ami_value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_2_id
  user_data_base64       = base64encode(file("${path.module}/userdata1.sh"))
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "web_server2"
  }
}