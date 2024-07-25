#!/bin/bash
# WEEEDebian creation script - a-porsia et al

#set -x
set -e

# this has to be done before sudo
echo "=== Set hostname ==="
echo "$MISO_HOSTNAME" >/etc/hostname
# HOSTNAME is the docker one, but it cannot be changed from
# the inside and is absolutely necessary to be set for sudo
# to determine that localhost is localhost
cat <<EOF >/etc/hosts
127.0.0.1       localhost $HOSTNAME $MISO_HOSTNAME
::1             localhost ip6-localhost ip6-loopback $HOSTNAME $MISO_HOSTNAME
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
# Something is overwriting /etc/hosts on each boot. What? Who knows!
# Here's a bug from 2010, but disabling NetworkManager does absolutely nothing:
# https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/659872
# Here's a solution with chattr, which does absolutely nothing (the attribute is not squashed probably):
# https://askubuntu.com/a/84526
# It seems to happen with PXE only. Since there's no way around it...

# cat <<EOF >/etc/hosts_fixed
# # This file was kindly placed here by /etc/cron.d/fix_etc_hosts
# # to work around whatever is overwriting it on boot.
#
# 127.0.0.1       localhost $MISO_HOSTNAME
# ::1             localhost ip6-localhost ip6-loopback $MISO_HOSTNAME
# ff02::1         ip6-allnodes
# ff02::2         ip6-allrouters
# EOF
# cp ./fix_etc_hosts /etc/cron.d/fix_etc_hosts
