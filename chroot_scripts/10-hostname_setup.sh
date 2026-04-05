#!/bin/bash
# WEEEDebian creation script - a-porsia et al

#set -x
#set -e

# this has to be done before sudo
echo "=== Set hostname ==="
echo "$MISO_HOSTNAME" >/etc/hostname
# HOSTNAME is the docker one, but it cannot be changed from
# the inside and is absolutely necessary to be set for sudo
# to determine that localhost is localhost
cat <<EOF >/etc/hosts
127.0.0.1       localhost $MISO_HOSTNAME $MISO_HOSTNAME
::1             localhost ip6-localhost ip6-loopback $MISO_HOSTNAME $MISO_HOSTNAME
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
