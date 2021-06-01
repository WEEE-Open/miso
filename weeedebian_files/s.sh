#!/bin/bash
# enable and start sshd, print local IP and interface

set -u

# systemctl enable --now sshd
if sudo systemctl start sshd ; then
    echo "ssh service started sucessfully."
    _INT=$(ip -4 route |awk '/^default/ {print $5}')
    _IPV4=$(ip addr show $_INT | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "Your local address is $_IPV4 on interface $_INT"
else
    echo "ssh service failed to start."
fi

read -p "Press enter to close"

