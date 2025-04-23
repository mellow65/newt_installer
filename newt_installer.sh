#!/bin/bash

set -e

echo "=== Newt VPN Setup Script ==="

# Prompt for input
read -p "Enter your Newt Endpoint URL: " ENDPOINT
read -p "Enter your Newt ID: " ID
read -p "Enter your Newt Secret: " SECRET

# Download and install Newt binary
echo "Downloading Newt binary..."
wget -q -O newt "https://github.com/fosrl/newt/releases/download/1.1.2/newt_linux_amd64"
chmod +x newt
mv newt /usr/local/bin/newt
echo "Newt installed to /usr/local/bin/newt"

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/newt.service"
echo "Creating systemd service at $SERVICE_FILE..."

bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Newt VPN Client
After=network.target

[Service]
ExecStart=/usr/local/bin/newt --id $ID --secret $SECRET --endpoint $ENDPOINT
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "Reloading systemd..."
systemctl daemon-reload
systemctl enable newt
systemctl start newt

echo "=== Newt VPN setup complete! ==="
systemctl status newt --no-pager
