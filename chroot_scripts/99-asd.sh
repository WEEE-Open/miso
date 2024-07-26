#!/bin/bash
# WEEEDebian creation script - a-porsia et al

echo "=== SSH daemon configuration ==="
cp ./sshd_config /etc/ssh/sshd_config

echo "=== Modules configuration ==="
_MODULES=("eeprom" "at24" "ee1004" "i2c-i801")
for i in ${!_MODULES[@]}; do
    if [[ ! -f "/etc/modules-load.d/${_MODULES[$i]}.conf" ]]; then
        printf "${_MODULES[$i]}\n" >/etc/modules-load.d/${_MODULES[$i]}.conf
    fi
done

echo "=== DNS configuration ==="
cp ./resolv.conf /etc/resolv.conf
cp ./resolved.conf /etc/systemd/resolved.conf
rm -f /var/run/NetworkManager/* 2>/dev/null

echo "=== NTP configuration ==="
systemctl enable systemd-timesyncd
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

echo "=== Top configuration ==="
cp ./toprc /root/.toprc
sudo -u $MISO_USERNAME cp ./toprc /home/$MISO_USERNAME/.toprc

echo "=== Prepare peracotta ==="
apt-get install -y python3-pip pipx

sudo -u $MISO_USERNAME pipx ensurepath
sudo -u $MISO_USERNAME pipx install peracotta

cp ./peracotta_update /etc/cron.d/peracotta_update

#sudo -u $MISO_USERNAME sh -c 'cd /home/$MISO_USERNAME/peracotta && python3 polkit.py'
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta # Ensure the dir exists
sudo -u $MISO_USERNAME cp ./features.json /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/features.json

echo "=== Add env to peracotta ==="
if [[ -f "./env.txt" ]]; then
    sudo -u $MISO_USERNAME cp ./env.txt /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/.env
else
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "@                         WARNING                          @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "@   env.txt not found in weeedebian/.                      @"
    echo "@   You're missing out many great peracotta features!      @"
    echo "@   Check README for more info if you want to create the   @"
    echo "@   file and automate your life!                           @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
fi

echo "=== s.sh ==="
cp ./s.sh /usr/sbin/s.sh
chmod +x /usr/sbin/s.sh
sudo -u $MISO_USERNAME cp ./ssh.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/ssh.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/ssh.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/ssh.desktop | awk '{print $1}')"

echo "=== XFCE configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4
rsync -a --force ./xfce4 /home/$MISO_USERNAME/.config
chown weee: -R /home/$MISO_USERNAME/.config
sudo -u $MISO_USERNAME cp ./light-locker.desktop /home/$MISO_USERNAME/.config/autostart/light-locker.desktop
# sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4/desktop /home/$MISO_USERNAME/.config/xfce4/terminal

echo "=== Desktop shortcuts ==="
#if [[ -d "/home/$MISO_USERNAME/limone" ]]; then
#  sudo -u $MISO_USERNAME git -C /home/$MISO_USERNAME/limone pull --ff-only
#else
#  sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/limone
#  sudo -u $MISO_USERNAME git clone https://github.com/WEEE-Open/limone.git /home/$MISO_USERNAME/limone
#fi
#
#for desktop_file in $(sudo -u $MISO_USERNAME find /home/$MISO_USERNAME/limone -name "*.desktop" -type f -printf "%f "); do
#  sudo -u $MISO_USERNAME cp "/home/$MISO_USERNAME/limone/$desktop_file" "/home/$MISO_USERNAME/Desktop/$desktop_file"
#  sudo -u $MISO_USERNAME chmod +x "/home/$MISO_USERNAME/Desktop/$desktop_file"
#  sed -ri -e "s#Icon=(.*/)*([a-zA-Z0-9\-\.]+)#Icon=/home/$MISO_USERNAME/limone/\2#" "/home/$MISO_USERNAME/Desktop/$desktop_file"
#done

sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open/tarallo
sudo -u $MISO_USERNAME cp ./Tarallo.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./tarallo.png /home/$MISO_USERNAME/.config/WEEE\ Open/tarallo/tarallo.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/Tarallo.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Tarallo.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/Tarallo.desktop | awk '{print $1}')"

sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open/wiki
sudo -u $MISO_USERNAME cp ./Wiki.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./limone.png /home/$MISO_USERNAME/.config/WEEE\ Open/wiki/wiki.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/Wiki.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Wiki.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/Wiki.desktop | awk '{print $1}')"

#if [[ -f "/home/$MISO_USERNAME/Desktop/PeracottaGUI.desktop" ]]; then
#  rm -f "/home/$MISO_USERNAME/Desktop/PeracottaGUI.desktop"
#fi
sudo -u $MISO_USERNAME cp ./Peracotta.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./peracotta.png /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/peracotta.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/Peracotta.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Peracotta.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/Peracotta.desktop | awk '{print $1}')"

sudo -u $MISO_USERNAME cp ./Peracruda.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./peracruda.png /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/peracruda.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/Peracruda.desktop
# su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Peracruda.desktop metadata::xfce-exe-checksum "$(sha256sum /home/$MISO_USERNAME/Desktop/Peracruda.desktop | awk '{print $1}')"

echo "=== Pointerkeys thing ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME cp ./Pointerkeys.desktop /home/$MISO_USERNAME/.config/autostart/Pointerkeys.desktop
sudo -u $MISO_USERNAME cp ./pointerkeys.txt /home/$MISO_USERNAME/Desktop

echo "=== Autologin stuff ==="
cat <<EOF >/etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user=$MISO_USERNAME
autologin-user-timeout=0
EOF
mkdir -p /etc/systemd/system/getty@.service.d
touch /etc/systemd/system/getty@.service.d/override.conf
printf "[Service]\n" >/etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=\n" >>/etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >>/etc/systemd/system/getty@.service.d/override.conf

echo "=== Final cleanup ==="
# Remove unused packages
apt-get autoremove -y
# Clean the cache
apt-get clean -y
rm -rf /var/lib/apt/lists/*

echo "=== Set hostname part 2 ==="
cat <<EOF >/etc/hosts
127.0.0.1       localhost $MISO_HOSTNAME
::1             localhost ip6-localhost ip6-loopback $MISO_HOSTNAME
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

echo "=== Set desktop shortcuts as trusted ==="
echo "@reboot weee f=/home/$MISO_USERNAME/Desktop/*.desktop; gio set -t string \$f metadata::xfce-exe-checksum \$(sha256sum \$f | awk '{print \$1}')" >/etc/cron.d/trust_desktop_shortcuts
