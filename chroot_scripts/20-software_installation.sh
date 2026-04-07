#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== Software installation ==="
export DEBIAN_FRONTEND=noninteractive

echo "Updating and cleaning..."
apt-get -qq update >/dev/null
apt-get -qq clean >/dev/null

echo "Upgrading packages..."
apt-get -qq -o Dpkg::Use-Pty=false -y upgrade >/dev/null

echo "Installing package list..."
apt-get -qq -o Dpkg::Use-Pty=false -y install $(grep -vE '^\s*#|^\s*$' resources/packages_list.txt) >/dev/null
