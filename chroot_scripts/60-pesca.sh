#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== Pesca ==="
sudo -u "$MISO_USERNAME" git clone https://github.com/weee-open/pesca /home/$MISO_USERNAME/pesca
sudo -u "$MISO_USERNAME" cp resources/pesca.sh /home/$MISO_USERNAME/pesca/pesca.sh
chmod +x /home/$MISO_USERNAME/pesca/pesca.sh
/home/$MISO_USERNAME/pesca/pesca.sh
