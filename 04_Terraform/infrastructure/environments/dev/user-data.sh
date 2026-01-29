#!/bin/bash
# User data script for EC2 instances

# Update system
yum update -y

# Install basic packages
yum install -y \
  curl \
  wget \
  git \
  htop \
  tree \
  unzip

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Create application directory
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Simple web server for testing
cat > /opt/app/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Enterprise Infrastructure - ${environment}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .info { background-color: #f1f1f1; padding: 10px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Enterprise Infrastructure</h1>
        <h2>Environment: ${environment}</h2>
    </div>
    <div class="content">
        <div class="info">
            <strong>Instance ID:</strong> <span id="instance-id"></span>
        </div>
        <div class="info">
            <strong>Region:</strong> <span id="region"></span>
        </div>
        <div class="info">
            <strong>Timestamp:</strong> <span id="timestamp"></span>
        </div>
    </div>
    <script>
        // Get instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/region')
            .then(response => response.text())
            .then(data => document.getElementById('region').textContent = data);
        
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Start simple HTTP server
cd /opt/app
nohup python3 -m http.server 80 > /var/log/webserver.log 2>&1 &

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
