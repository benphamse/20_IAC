#!/bin/bash
# Update package lists and install required packages
apt update -y
apt install -y apache2 awscli curl

# Get the instance ID using the instance metadata service
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create a simple HTML file with improved styling
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Portfolio</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 0;
      padding: 20px;
      text-align: center;
    }
    .container {
      max-width: 800px;
      margin: 0 auto;
      border: 1px solid #ddd;
      padding: 20px;
      border-radius: 5px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    @keyframes colorChange {
      0% { color: #ff5757; }
      50% { color: #57c557; }
      100% { color: #5757ff; }
    }
    h1 {
      animation: colorChange 3s infinite;
    }
    .instance-info {
      background-color: #f5f5f5;
      padding: 10px;
      border-radius: 5px;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Terraform Project Server</h1>
    <div class="instance-info">
      <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
      <h3>Availability Zone: <span style="color:blue">$AVAILABILITY_ZONE</span></h3>
    </div>
    <p>Welcome to CloudChamp's Channel</p>
  </div>
</body>
</html>
EOF

# Enable and start Apache
systemctl start apache2
systemctl enable apache2

# Print completion message to log
echo "Server setup completed successfully!"