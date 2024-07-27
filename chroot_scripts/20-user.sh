#!/bin/bash

#set -x
set -e

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
sudo -u $MISO_USERNAME curl -L -o /home/$MISO_USERNAME/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
cp /home/$MISO_USERNAME/.zshrc /root/.zshrc

sudo -u $MISO_USERNAME rm /home/$MISO_USERNAME/.bash_history >/dev/null 2>/dev/null
rm /root/.bash_history >/dev/null 2>/dev/null

echo "=== Top configuration ==="
cp ./toprc /root/.toprc
sudo -u $MISO_USERNAME cp ./toprc /home/$MISO_USERNAME/.toprc

echo "=== XFCE configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4
rsync -a --force ./xfce4 /home/$MISO_USERNAME/.config
chown weee: -R /home/$MISO_USERNAME/.config
#echo "export XDG_DATA_DIRS=$XDG_DATA_DIRS:$HOME/Desktop >> $HOME/.zprofile"
echo 'export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/Desktop"' | sudo tee /etc/profile
sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/autostart/light-locker.desktop <<EOF
[Desktop Entry]
Hidden=true
EOF
# sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4/desktop /home/$MISO_USERNAME/.config/xfce4/terminal
