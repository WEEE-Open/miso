#!/bin/bash

echo "=== Locale configuration ==="
sudo tee /etc/locale.gen <<EOF
it_IT.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
sudo tee /etc/locale.conf <<EOF
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_CTYPE=it_IT.UTF-8
LC_NUMERIC=it_IT.UTF-8
LC_TIME=it_IT.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=it_IT.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=it_IT.UTF-8
LC_NAME=it_IT.UTF-8
LC_ADDRESS=it_IT.UTF-8
LC_TELEPHONE=it_IT.UTF-8
LC_MEASUREMENT=it_IT.UTF-8
LC_IDENTIFICATION=it_IT.UTF-8
EOF

locale-gen
update-locale
# . /etc/locale.conf
# Prints POSIX everywhere despite different variables have just been sourced.
# Whatever, it is correct once boot.
# locale

echo "=== Keymap configuration ==="
# Needed for sure on Debian 11:
sudo tee /etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="it,us"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF
# Keyboard layout switcher:
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/autostart/fbxkb.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=fbxkb
Comment=Keyboard layout switcher
Exec=fbxkb
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF
# 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
# May not be needed in Debian 11:
#mkdir -p /etc/X11/xorg.conf.d
#cp ./00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
#echo "KEYMAP=it" >/etc/vconsole.conf
