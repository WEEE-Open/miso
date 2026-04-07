#!/bin/bash

sudo systemctl disable lightdm || true

sudo tee /etc/X11/Xwrapper.config <<EOF >/dev/null
allowed_users=anybody
EOF

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf <<EOF >/dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $MISO_USERNAME --noclear %%I \$TERM
EOF

tee /home/$MISO_USERNAME/.bash_profile <<EOF >/dev/null
if [[ -z "\$DISPLAY" && "\$(tty)" =~ tty1 ]]; then
    exec startx /usr/local/bin/wizard.sh -- :0
fi
EOF
