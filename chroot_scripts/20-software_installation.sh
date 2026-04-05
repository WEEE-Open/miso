#!/bin/bash
# WEEEDebian creation script - a-porsia et al

#set -x
#set -e

echo "=== Software installation ==="
export DEBIAN_FRONTEND=noninteractive

apt-get -qq -o Dpkg::Use-Pty=false -y clean >/dev/null
apt-get -qq -o Dpkg::Use-Pty=false -y update >/dev/null

# Upgrade and install useful packages
apt-get -qq -o Dpkg::Use-Pty=false -y upgrade >/dev/null

# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
apt-get -qq -o Dpkg::Use-Pty=false -y install $(grep -vE '^\s*#|^\s*$' resources/packages_list.txt) >/dev/null
