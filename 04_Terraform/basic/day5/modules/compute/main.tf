resource "aws_instance" "web_server1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_1_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/media/benpham/WORK/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.cwd}/../scripts/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-flask",
      "sudo bash -c 'nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 </dev/null &'",
      "sleep 2"
    ]
  }

  tags = {
    Name = "web_server1"
  }
}

resource "null_resource" "cluster_info" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/media/benpham/WORK/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem")
    host        = aws_instance.web_server1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Current workspace: ${terraform.workspace}' > cluster_info.txt"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i /media/benpham/WORK/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem ubuntu@${aws_instance.web_server1.public_ip}:cluster_info.txt ."
  }
}

resource "terraform_data" "cluster_info" {
  triggers_replace = [
    aws_instance.web_server1.public_ip
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/media/benpham/WORK/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem")
    host        = aws_instance.web_server1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Current workspace: ${terraform.workspace}' > cluster_info.txt"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i /media/benpham/WORK/03_WorkSpace/01_SourceCode/19_DevopsForFresher/06_aws/key/terraform.pem ubuntu@${aws_instance.web_server1.public_ip}:cluster_info.txt ."
  }
}
