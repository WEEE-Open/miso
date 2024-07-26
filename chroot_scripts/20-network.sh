#!/bin/bash

#set -x
set -e

update-ca-certificates
systemctl disable smartd
sudo tee /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
EOF
sudo chmod 644 /etc/NetworkManager/NetworkManager.conf
systemctl enable NetworkManager
