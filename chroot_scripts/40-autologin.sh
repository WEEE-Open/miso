#!/bin/bash

echo "=== Autologin stuff ==="
cat <<EOF >/etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user=$MISO_USERNAME
autologin-user-timeout=0
EOF
mkdir -p /etc/systemd/system/getty@.service.d
touch /etc/systemd/system/getty@.service.d/override.conf
printf "[Service]\n" >/etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=\n" >>/etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >>/etc/systemd/system/getty@.service.d/override.conf
