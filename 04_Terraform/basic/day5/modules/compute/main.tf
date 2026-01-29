resource "aws_instance" "web_server1" {
  ami                    = var.ami_value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_1_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name # Ensure you have a key pair created in AWS

  connection {
    type        = "ssh"
    user        = "ubuntu" # Replace with the appropriate username for your EC2 instance
    private_key = file("/mnt/d/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem")
    # Replace with the path to your private key
    host = self.public_ip
  }

  provisioner "file" {
    source      = "${path.root}/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "sudo pip3 install flask",
      "nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 &",
      "sleep 5" # Give the app time to start
    ]
  }

  tags = {
    Name = "web_server1"
  }
}
