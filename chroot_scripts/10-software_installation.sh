#!/bin/bash
# WEEEDebian creation script - a-porsia et al

#set -x
#set -e

echo "=== Software installation ==="
export DEBIAN_FRONTEND=noninteractive

# Add vscodium repository
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

apt-get -qq -o Dpkg::Use-Pty=false -y clean >/dev/null
apt-get -qq -o Dpkg::Use-Pty=false -y update >/dev/null

# Remove useless packages, courtesy of "wajig large". Cool command.
# Do not remove mousepad, it removes xfce-goodies too
# /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
# This is commented because none of these packages is present at this time

# Upgrade and install useful packages
apt-get -qq -o Dpkg::Use-Pty=false -y upgrade >/dev/null



# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
apt-get -qq -o Dpkg::Use-Pty=false -y install \
    alsa-firmware-loaders \
    apt-transport-https \
    atmel-firmware \
    bluez-firmware \
    cifs-utils \
    codium \
    cron \
    curl \
    dmidecode \
    dnsutils \
    eject \
    fd-find \
    firefox-esr \
    firmware-linux \
    firmware-bnx2 \
    firmware-bnx2x \
    firmware-brcm80211 \
    firmware-iwlwifi \
    firmware-netxen \
    firmware-realtek \
    firmware-samsung \
    firmware-intel-sound \
    firmware-ti-connectivity \
    firmware-zd1211 \
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
    less \
    libglib2.0-bin \
    libglu1-mesa-dev \
    libx11-xcb-dev \
    libxi-dev \
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
    pavucontrol \
    pciutils \
    python3 \
    python3-venv \
    python3-venv \
    python-is-python3 \
    libxcb-cursor0 \
    libxcb-cursor0 \
    ripgrep \
    rsync \
    smartmontools \
    strace \
    systemd-timesyncd \
    systemd-timesyncd \
    traceroute \
    vim \
    wireless-tools \
    wpagui \
    xdg-utils \
    xfce4 \
    xfce4-terminal \
    xfce4-xkb-plugin \
    xfce4-whiskermenu-plugin \
    xinit \
    xorg \
    xserver-xorg \
    zip \
    zsh \
    >/dev/null

chsh -s /bin/zsh root
