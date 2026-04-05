#!/bin/bash

sudo systemctl disable lightdm || true

sudo tee /etc/X11/Xwrapper.config < allowed_users=anybody

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo printf "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin oem --noclear %%I \$TERM\n" > /etc/systemd/system/getty@tty1.service.d/override.conf

tee /home/oem/.bash_profile <<EOF
if [[ -z "\$DISPLAY" && "\$(tty)" =~ tty1 ]]; then
    exec startx /usr/local/bin/wizard.sh -- :0
fi
EOF
