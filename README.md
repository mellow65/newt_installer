# newt_installer
Short script to set up a systemd service of Newt for Pangolin.  This script only looks for the Linux variants, and allows you to select your CPU and pulls the latest Newt file.  
https://github.com/fosrl/pangolin

Download Newt Installer
```bash
wget -O newt_installer.sh "https://raw.githubusercontent.com/mellow65/newt_installer/refs/heads/main/newt_installer.sh" && chmod +x ./newt_installer.sh
```

Run Newt Installer
```bash
./newt_installer.sh
```

Sometimes if you start your service on your home server before confirming the site in Pangolin you might need to restart the service.
```bash
systemctl restart newt.service
```
