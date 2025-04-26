#!/bin/bash

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ID)
      ID="$2"
      shift 2
      ;;
    --SECRET)
      SECRET="$2"
      shift 2
      ;;
    --ENDPOINT)
      ENDPOINT="$2"
      shift 2
      ;;
    --VERSION)
      VERSION="$2"
      shift 2
      ;;
    --ARCHITECTURE)
      ARCHITECTURE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done



# Reminder to visit Pangolin site
echo "Please go back to the Pangolin site and click 'Create Site' then 'Save Settings'."
echo "Once you have completed those steps, return here and press Enter to continue."
read -p "Press Enter to continue..."


LATEST_URL="https://github.com/fosrl/newt/releases/download/${VERSION}/${ARCHITECTURE}"

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
