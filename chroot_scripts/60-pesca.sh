#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== Pesca ==="
sudo -u "$MISO_USERNAME" git clone https://github.com/weee-open/pesca /home/$MISO_USERNAME/pesca
chmod +x /home/$MISO_USERNAME/pesca/pesca.sh
