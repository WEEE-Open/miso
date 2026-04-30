#!/bin/bash

echo "=== Set default dotfiles ==="
mkdir -p /etc/skel/.config
sudo cp -r config/. /etc/skel/.config/
