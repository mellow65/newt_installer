# newt_installer
Short script to set up a systemd service of Newt for Pangolin.    
https://github.com/fosrl/pangolin

Script can do fresh install, update exsisting install with new site information, update Newt to latest version, remove Newt and assosociated service entries.  
Download Newt Installer
```bash
sudo wget -O newt_installer.sh "https://raw.githubusercontent.com/mellow65/newt_installer/refs/heads/main/newt_installer.sh" && sudo chmod +x ./newt_installer.sh
```

Run Newt Installer
```bash
sudo ./newt_installer.sh
```

Sometimes if you start your service on your home server before confirming the site in Pangolin you might need to restart the service.
```bash
systemctl restart newt.service
```
