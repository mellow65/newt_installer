#!/bin/bash

set -e

echo "=== Newt VPN Setup / Update Script ==="

# Ask user if this is an update
read -p "Is this an update to an existing installation? (y/n): " IS_UPDATE
IS_UPDATE=${IS_UPDATE,,} # lowercase the response

if [[ "$IS_UPDATE" != "y" ]]; then
    # Get credentials and info if not updating
    read -p "Enter your Newt Endpoint URL: " ENDPOINT
    read -p "Enter your Newt ID: " ID
    read -p "Enter your Newt Secret: " SECRET

    echo "Please go back to the Pangolin site and click 'Create Site' then 'Save Settings'."
    echo "Once you have completed those steps, return here and press Enter to continue."
    read -p "Press Enter to continue..."
fi

# Prompt user to select the desired Linux version
echo "Select the Linux version of Newt to install:"
echo "1. linux_amd64"
echo "2. linux_arm32"
echo "3. linux_arm32v6"
echo "4. linux_arm64"
echo "5. linux_riscv64"

read -p "Enter the number corresponding to your choice: " VERSION_CHOICE

case "$VERSION_CHOICE" in
  1) ARCH_SUFFIX="linux_amd64" ;;
  2) ARCH_SUFFIX="linux_arm32" ;;
  3) ARCH_SUFFIX="linux_arm32v6" ;;
  4) ARCH_SUFFIX="linux_arm64" ;;
  5) ARCH_SUFFIX="linux_riscv64" ;;
  *) echo "❌ Invalid choice. Exiting."; exit 1 ;;
esac

# Get latest release URL from GitHub
echo "Fetching latest Newt release for: $ARCH_SUFFIX..."
LATEST_URL=$(curl -s https://api.github.com/repos/fosrl/newt/releases/latest \
  | grep "browser_download_url" \
  | grep "$ARCH_SUFFIX" \
  | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
  echo "❌ Failed to retrieve latest release URL for $ARCH_SUFFIX."
  exit 1
fi

# Check if systemd service file already exists
SERVICE_FILE="/etc/systemd/system/newt.service"
if [ -f "$SERVICE_FILE" ]; then
    SERVICE_EXISTS=true
    echo "ℹ️ Detected existing Newt systemd service."
else
    SERVICE_EXISTS=false
    echo "ℹ️ No existing systemd service found."
fi

# Stop service if it exists
if [ "$SERVICE_EXISTS" = true ]; then
    echo "🔄 Stopping Newt service..."
    systemctl stop newt
fi

# Download and install the binary
echo "⬇️ Downloading Newt from: $LATEST_URL"
wget -q -O newt "$LATEST_URL"
chmod +x newt
mv newt /usr/local/bin/newt
echo "✅ Newt installed to /usr/local/bin/newt"

# Only create the service file if it's a new install
if [ "$IS_UPDATE" != "y" ]; then
    echo "🛠 Creating systemd service at $SERVICE_FILE..."
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

    echo "🔄 Reloading systemd and enabling Newt service..."
    systemctl daemon-reload
    systemctl enable newt
fi

# Start the service
echo "▶️ Starting Newt service..."
systemctl start newt

echo "=== ✅ Newt setup/update complete! ==="
systemctl status newt --no-pager
