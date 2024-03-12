#!/bin/bash

# Ensure root user
sudo su

# Update system
yum update -y

# Install Python 3, pip, cloudwatch logs agent, collectd for system logs
yum install -y python3 python3-pip amazon-cloudwatch-agent collectd

# Install dependencies
pip3 install flask gunicorn

# Install aws-cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# Fetch application code
sudo /usr/local/bin/aws s3 cp s3://${s3_bucket} /home/ec2-user/ --recursive
sudo chmod +x /home/ec2-user/app.py

# Setup Web Server to run as daemon process
echo '
[Unit]
Description=Gunicorn instance for a simple web server
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/local/bin/gunicorn -b 0.0.0.0:80 app:app

Restart=always

[Install]
WantedBy=multi-user.target
' >/etc/systemd/system/web-server.service

# Reload daemon processes
systemctl daemon-reload

# Start web server
systemctl start web-server

# Enable daemon in systemd to run on startup
systemctl enable web-server

# Print status to logfile: /var/log/cloud-init-output.log
systemctl status web-server
