#!/bin/bash
# set -x

# crea utente temporaneo
useradd -m -p "" -s /bin/bash oem
passwd -d oem
usermod -aG sudo oem
echo "oem ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/oem

cp resources/wizard.sh /home/oem/
cp resources/prepare_for_donation.sh /home/oem
cp resources/finish_install.sh /home/oem

chmod +x /home/oem/*.sh

# autologin
tee /etc/lightdm/lightdm.conf <<EOF >/dev/null
[Seat:*]
autologin-user=oem
autologin-user-timeout=0
EOF
