#!/bin/bash

# Update system
sudo apt update

# Install dependencies
pip install flask gunicorn

# Create project root directory
mkdir web-server
cd web-server

# Fetch web-server application code
# curl www.github.com/garrettohara/web-server/

# Setup Web Server to run as daemon process
echo <<'EOF' >/etc/systemd/system/web-server.service
[Unit]
Description=Gunicorn instance for a simple web server
After=network.target
[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/web-server
ExecStart=gunicorn -b localhost:8000 app:app
Restart=always
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl start web-server
sudo systemctl enable web-server
