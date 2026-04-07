#!/bin/bash
# set -x

# temp user, will be delated in finish_install.sh
useradd -m -p "" -s /bin/bash $MISO_USERNAME
passwd -d $MISO_USERNAME
usermod -aG sudo $MISO_USERNAME
echo "$MISO_USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$MISO_USERNAME

sudo -u "$MISO_USERNAME" cp resources/wizard.sh /home/$MISO_USERNAME/
sudo -u "$MISO_USERNAME" cp resources/prepare_for_donation.sh /home/$MISO_USERNAME
sudo -u "$MISO_USERNAME" cp resources/finish_install.sh /home/$MISO_USERNAME

chmod +x /home/$MISO_USERNAME/*.sh

# autologin
tee /etc/lightdm/lightdm.conf <<EOF >/dev/null
[Seat:*]
autologin-user=$MISO_USERNAME
autologin-user-timeout=0
EOF
