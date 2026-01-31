#!/bin/bash

sudo apt update
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2

echo "Apache2 installed and started successfully. You can access it at http://$(hostname -I)" > /var/www/html/index.html