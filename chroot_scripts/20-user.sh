#!/bin/bash

#set -x
#set -e

echo "=== User configuration ==="
# openssl has been installed, so this can be done now
MISO_ROOTPASSWD=$(openssl passwd -6 "$MISO_ROOTPASSWD")
MISO_USERPASSWD=$(openssl passwd -6 "$MISO_USERPASSWD")
if [[ -z $(grep weee /etc/passwd) ]]; then
    useradd -m -G sudo -s /bin/zsh weee
fi
# The -p parameter is silently ignored for some reason:
# -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
# This ALSO does not work:
#echo "weee:asd" | chpasswd
# So...
sed -i "s#root:.*#root:$ROOTPASSWD:18214:0:99999:7:::#" /etc/shadow
sed -i "s#$MISO_USERNAME:.*#$MISO_USERNAME:$MISO_USERPASSWD:18214:0:99999:7:::#" /etc/shadow

echo "=== Sudo configuration ==="
sudo tee /etc/sudoers.d/$MISO_USERNAME <<EOF
Defaults lecture = never
weee ALL=(ALL) NOPASSWD: ALL
EOF

echo "=== Shell and home configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/Desktop
# sudo -u $MISO_USERNAME ln -sf ./Desktop /home/$MISO_USERNAME/Scrivania
# chsh -s /bin/zsh weee
sudo -u $MISO_USERNAME curl -sL -o /home/$MISO_USERNAME/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc >/dev/null
cp /home/$MISO_USERNAME/.zshrc /root/.zshrc

sudo -u $MISO_USERNAME rm /home/$MISO_USERNAME/.bash_history >/dev/null
rm /root/.bash_history >/dev/null

echo "=== Top configuration ==="
cp ./resources/toprc /root/.toprc
sudo -u $MISO_USERNAME cp ./resources/toprc /home/$MISO_USERNAME/.toprc

echo "=== XFCE configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4
rsync -a --force ./xfce4 /home/$MISO_USERNAME/.config
chown weee: -R /home/$MISO_USERNAME/.config
# All the launchers in XDG_DATA_DIRS are automatically trusted and don't need the checksum. For some reason nothing of what I tried could properly set that variable on startup, so I ended up using an autostart script to trust all the *.desktop files in $HOME/Desktop (in 40-desktop.sh)
#echo "export XDG_DATA_DIRS=$XDG_DATA_DIRS:$HOME/Desktop >> $HOME/.zprofile"
#echo 'export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/Desktop"' | sudo tee /etc/profile
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/autostart/light-locker.desktop <<EOF >/dev/null
[Desktop Entry]
Hidden=true
EOF
mkdir -p /usr/share/pixmaps/weee
cp ./img/logo.png /usr/share/pixmaps/weee
cp ./img/weeellpaper.jpg /usr/share/backgrounds
# sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4/desktop /home/$MISO_USERNAME/.config/xfce4/terminal
