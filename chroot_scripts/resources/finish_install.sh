#!/bin/bash

set -x
export DISPLAY=:0

#
sudo hostnamectl set-hostname "$NEW_HOST"
sudo sed -i "s/$MISO_HOSTNAME/$NEW_HOST/g" /etc/hosts
sudo adduser --quiet --disabled-password --gecos "" "$NEW_USER"
echo "$NEW_USER:$NEW_PASS" | sudo chpasswd
sudo usermod -aG sudo,audio,video,plugdev,netdev,bluetooth "$NEW_USER"

# Cleanup
sudo sed -i 's/NODM_ENABLED=true/NODM_ENABLED=false/' /etc/default/nodm
echo "/usr/sbin/lightdm" | sudo tee /etc/X11/default-display-manager
sudo systemctl disable nodm
sudo systemctl enable lightdm
sudo rm /etc/sudoers.d/oem
sudo userdel -f oem
sudo rm -rf /tmp/pesca
sudo rm /tmp/setup.sh
sudo rm /tmp/wizard.sh
sudo rm /tmp/finish_install.sh
sudo apt-get remove yad git
sudo apt-get update && sudo apt-get upgrade

yad --info --text="Success. The PC will reboot with the new configuration."
sleep 10
sudo reboot
