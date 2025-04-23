#!/bin/bash

set -e

echo "=== Newt VPN Setup Script ==="

# Prompt for user inputs
read -p "Enter your Newt Endpoint URL: " ENDPOINT
read -p "Enter your Newt ID: " ID
read -p "Enter your Newt Secret: " SECRET

# Reminder to visit Pangolin site
echo "Please go back to the Pangolin site and click 'Create Site'."
echo "Once you have completed that step, return here and press Enter to continue."
read -p "Press Enter to continue..."

# Get latest release URL from GitHub
echo "Fetching latest Newt release..."
LATEST_URL=$(curl -s https://api.github.com/repos/fosrl/newt/releases/latest \
  | grep "browser_download_url" \
  | grep "linux_amd64" \
  | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
  echo "❌ Failed to retrieve latest release URL."
  exit 1
fi

echo "Downloading Newt from: $LATEST_URL"
wget -q -O newt "$LATEST_URL"
chmod +x newt
mv newt /usr/local/bin/newt
echo "✅ Newt installed to /usr/local/bin/newt"

# Create the systemd service file
SERVICE_FILE="/etc/systemd/system/newt.service"
echo "Creating systemd service at $SERVICE_FILE..."

sudo bash -c "cat > $SERVICE_FILE" <<EOF
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

# Reload systemd and enable the service
echo "Reloading systemd and enabling Newt service..."
systemctl daemon-reload
systemctl enable newt
systemctl start newt

echo "=== ✅ Newt VPN setup complete! ==="
systemctl status newt --no-pager
