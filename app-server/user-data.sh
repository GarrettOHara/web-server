#!/bin/bash

# Ensure root user
sudo su

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install dependencies
pip3 install flask gunicorn

# Fetch application code
curl -O https://raw.githubusercontent.com/GarrettOHara/web-server/main/app.py

# Setup Web Server to run as daemon process
echo >/etc/systemd/system/web-server.service <<'EOF'
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
EOF

# Reload daemon processes
systemctl daemon-reload

# Start web server
systemctl start web-server

# Enable daemon in systemd to run on startup
systemctl enable web-server
