#!/bin/bash
#
# set -x

echo "=== Desktop shortcuts ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.local/share/WEEE\ Open
sudo -u $MISO_USERNAME mkdir -p "/home/$MISO_USERNAME/Desktop"

for file in ./desktop/*.desktop; do
    envsubst < "$file" | sudo -u "$MISO_USERNAME" tee "/home/$MISO_USERNAME/Desktop/$(basename "$file")" >/dev/null

    filename=$(basename -s .desktop $file)
    sudo -u "$MISO_USERNAME" cp "./img/$filename.png" "/home/$MISO_USERNAME/.local/share/WEEE Open/"
    sudo -u "$MISO_USERNAME" chmod +x "/home/$MISO_USERNAME/Desktop/$filename.desktop"
done


echo "=== Desktop sessions ==="
mkdir -p /etc/lightdm/lightdm.conf.d
mkdir -p /usr/share/xsessions
mkdir -p /usr/share/wayland-sessions

cp resources/choose-session.sh /usr/local/bin/choose-session.sh
chmod +x /usr/local/bin/choose-session.sh

# Auto
tee /usr/share/xsessions/miso-auto.desktop <<EOF >/dev/null
[Desktop Entry]
Name=MISO Auto (Wayland/X11)
Exec=/usr/local/bin/choose-session.sh
Type=Application
EOF

# # Wayland
# tee /usr/share/xsessions/miso-wayland.desktop <<EOF >/dev/null
# [Desktop Entry]
# Name=MISO Wayland (Labwc)
# Exec=env MISO_FORCE_SESSION=wayland /usr/local/bin/choose-session.sh
# Type=Application
# EOF

# # X11
# tee /usr/share/xsessions/miso-x11.desktop <<EOF >/dev/null
# [Desktop Entry]
# Name=MISO X11 (Openbox)
# Exec=env MISO_FORCE_SESSION=x11 /usr/local/bin/choose-session.sh
# Type=Application
# EOF

# Default Auto
echo "[Seat:*]
user-session=miso-auto" | tee /etc/lightdm/lightdm.conf.d/20-miso.conf >/dev/null

# Hide standard sessions - would boot without DE
# for session in lxqt openbox labwc; do
#     # Per X11
#     if [ -f "/usr/share/xsessions/${session}.desktop" ]; then
#         sed -i '/NoDisplay=/d' "/usr/share/xsessions/${session}.desktop"
#         echo "NoDisplay=true" | tee -a "/usr/share/xsessions/${session}.desktop" > /dev/null
#     fi
#     # Per Wayland
#     if [ -f "/usr/share/wayland-sessions/${session}.desktop" ]; then
#         sed -i '/NoDisplay=/d' "/usr/share/wayland-sessions/${session}.desktop"
#         echo "NoDisplay=true" | tee -a "/usr/share/wayland-sessions/${session}.desktop" > /dev/null
#     fi
# done

# echo "=== Set Wallpaper ==="
# mkdir -p /usr/share/images/desktop-base
# cp img/weeellpaper.jpg /usr/share/images/desktop-base/weeellpaper.jpg

echo "=== Trust .desktop files ==="
sudo sed -i 's/^QuickExec=false/QuickExec=true/' "/home/$MISO_USERNAME/.config/pcmanfm-qt/lxqt/settings.conf"
# find config -type f -exec bash -c 'target="/home/$MISO_USERNAME/.config/${1#config/}"; mkdir -p "$(dirname "$target")"; envsubst < "$1" | sudo -u "$MISO_USERNAME" tee "$target" >/dev/null' _ {} \;done
