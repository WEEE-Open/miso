#!/bin/bash
# WEEEDebian creation script - a-porsia et al

set -x
set -e

echo "=== Software installation ==="
export DEBIAN_FRONTEND=noninteractive

apt-get clean -y
apt-get update -y
apt-get install -y software-properties-common # add `apt-add-repository` command

# Add non-free repo and update to pull in all the good firmware
# apt-add-repository non-free 2>&1 # since bookworm non free firmware is its own component. See https://www.debian.org/releases/bookworm/amd64/release-notes/ch-information.html#non-free-split
# For now, we are not installing any non-free package that isn't a firmware so this is not needed
apt-add-repository non-free-firmware 2>&1
apt-add-repository contrib 2>&1

apt-get update -y

# Remove useless packages, courtesy of "wajig large". Cool command.
# Do not remove mousepad, it removes xfce-goodies too
# /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
# This is commented because none of these packages is present at this time

# Upgrade and install useful packages
apt-get upgrade -y
# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
apt-get install -y \
    alsa-firmware-loaders \
    apt-transport-https \
    atmel-firmware \
    bluez-firmware \
    ca-certificates \
    cifs-utils \
    curl \
    dmidecode \
    dnsutils \
    firefox-esr \
    firmware-linux \
    firmware-atheros \
    firmware-bnx2 \
    firmware-bnx2x \
    firmware-brcm80211 \
    firmware-cavium \
    firmware-intel-sound \
    firmware-iwlwifi \
    firmware-libertas \
    firmware-myricom \
    firmware-netronome \
    firmware-netxen \
    firmware-qcom-media \
    firmware-qcom-soc \
    firmware-qlogic \
    firmware-realtek \
    firmware-samsung \
    firmware-siano \
    firmware-ti-connectivity \
    firmware-zd1211 \
    geany \
    git \
    gparted \
    gsmartcontrol \
    gvfs-backends \
    hdparm \
    i2c-tools \
    iproute2 \
    iputils-arping \
    iputils-ping \
    iputils-tracepath \
    libglu1-mesa-dev \
    libx11-xcb-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-0 \
    libxkbcommon-x11-dev \
    libxrender-dev \
    lightdm \
    lm-sensors \
    locales \
    lshw \
    mesa-utils \
    nano \
    net-tools \
    network-manager \
    network-manager-gnome \
    openssh-client \
    openssh-server \
    openssl \
    pciutils \
    python3 \
    python3-venv \
    python3-venv \
    python-is-python3 \
    libxcb-cursor0 \
    libxcb-cursor0 \
    rsync \
    smartmontools \
    strace \
    sudo \
    systemd-timesyncd \
    systemd-timesyncd \
    traceroute \
    wget \
    wireless-tools \
    wpagui \
    xfce4 \
    xfce4-terminal \
    xfce4-whiskermenu-plugin \
    xinit \
    xorg \
    xserver-xorg \
    zsh
