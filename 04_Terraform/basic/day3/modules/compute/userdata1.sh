#!/bin/bash
apt update -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<h1>Web Server 2 - Hello from EC2!</h1>" > /var/www/html/index.html