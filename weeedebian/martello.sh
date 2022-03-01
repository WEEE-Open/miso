#!/bin/bash
# WEEEDebian creation script - a-porsia et al
# export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"

echo "Martello is starting!"

echo "=== Install kernel and systemd ==="
DEBIAN_FRONTEND=noninteractive apt-get -qq update -y -o Dpkg::Use-Pty=false
DEBIAN_FRONTEND=noninteractive apt-get -qq install -y -o Dpkg::Use-Pty=false \
    --no-install-recommends \
    linux-image-$MISO_ARCH \
    live-boot \
    systemd-sysv \
    apt-utils

# this has to be done before sudo
echo "=== Set hostname ==="
echo "$MISO_HOSTNAME" > /etc/hostname
# HOSTNAME is the docker one, but it cannot be changed from
# the inside and is absolutely necessary to be set for sudo
# to determine that localhost is localhost
cat << EOF > /etc/hosts
127.0.0.1       localhost $MISO_HOSTNAME $HOSTNAME
::1             localhost ip6-localhost ip6-loopback $MISO_HOSTNAME $HOSTNAME
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

echo "=== Software installation ==="
# Remove useless packages, courtesy of "wajig large". Cool command.
# Do not remove mousepad, it removes xfce-goodies too
#/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
# Upgrade and install useful packages
export DEBIAN_FRONTEND=noninteractive
apt-get -qq upgrade -y -o Dpkg::Use-Pty=false
# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
apt-get -qq install -y -o Dpkg::Use-Pty=false \
    apt-transport-https \
    ca-certificates \
    cifs-utils \
    curl \
    dmidecode \
    dnsutils \
    fbxkb \
    firefox-esr \
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
    openssh-client \
    openssh-server \
    openssl \
    pciutils \
    python3 \
    python-is-python3 \
    rsync \
    smartmontools \
    strace \
    sudo \
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
    xserver-xorg-core \
    zsh
update-ca-certificates

echo "=== User configuration ==="
# openssl has been installed, so this can be done now
MISO_ROOTPASSWD=$(openssl passwd -6 "$MISO_ROOTPASSWD")
MISO_USERPASSWD=$(openssl passwd -6 "$MISO_USERPASSWD")
if [[ -z `grep weee /etc/passwd` ]]; then
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
cp ./$MISO_USERNAME /etc/sudoers.d/$MISO_USERNAME

echo "=== Shell and home configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/Desktop
# sudo -u $MISO_USERNAME ln -sf ./Desktop /home/$MISO_USERNAME/Scrivania
chsh -s /bin/zsh root
# chsh -s /bin/zsh weee
sudo -u $MISO_USERNAME curl -L -o /home/$MISO_USERNAME/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
cp /home/$MISO_USERNAME/.zshrc /root/.zshrc
sudo -u $MISO_USERNAME rm /home/$MISO_USERNAME/.bash_history  >/dev/null 2>/dev/null
rm /root/.bash_history >/dev/null 2>/dev/null

echo "=== Keymap configuration ==="
# Needed for sure on Debian 11:
cp ./keyboard /etc/default/keyboard
# Keyboard layout switcher:
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME cp ./fbxkb.desktop /home/$MISO_USERNAME/.config/autostart/fbxkb.desktop
# 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
# May not be needed in Debian 11:
mkdir -p /etc/X11/xorg.conf.d
cp ./00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
echo "KEYMAP=it" > /etc/vconsole.conf

echo "=== Locale configuration ==="
cp ./locale.gen /etc/locale.gen
cp ./locale.conf /etc/locale.conf
locale-gen
unset LANG
. /etc/locale.conf
# Prints POSIX everywhere despite different variables have just been sourced.
# Whatever, it is correct once boot.
# locale

echo "=== SSH daemon configuration ==="
cp ./sshd_config /etc/ssh/sshd_config

echo "=== Modules configuration ==="
_MODULES=("eeprom" "at24" "ee1004" "i2c-i801")
for i in ${!_MODULES[@]}; do
  if [[ ! -f "/etc/modules-load.d/${_MODULES[$i]}.conf" ]]; then
    printf "${_MODULES[$i]}\n" > /etc/modules-load.d/${_MODULES[$i]}.conf
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
apt-get -qq install -y python3-pip -o Dpkg::Use-Pty=false
# PyQt > 5.14.0 requires an EXTREMELY RECENT version of pip,
# on the most bleeding of all bleeding edges
# python3 -m pip install --quiet --upgrade pip

cp ./peracotta_update /etc/cron.d/peracotta_update

if [[ -d "/home/$MISO_USERNAME/peracotta" ]]; then
  sudo -u $MISO_USERNAME git -C /home/$MISO_USERNAME/peracotta pull --ff-only
else
  sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/peracotta
  sudo -u $MISO_USERNAME git clone https://github.com/WEEE-Open/peracotta.git /home/$MISO_USERNAME/peracotta
fi

#sudo -u $MISO_USERNAME sh -c 'cd /home/$MISO_USERNAME/peracotta && python3 polkit.py'
sudo -u $MISO_USERNAME cp ./features.json /home/$MISO_USERNAME/peracotta/features.json

if [[ "$MISO_ARCH" == "i386" ]]; then
  echo "===== Begin incredible workaround for PyQt on 32 bit ====="
  apt-get -qq install -y python3-pyqt5 -o Dpkg::Use-Pty=false
  sudo -u $MISO_USERNAME /bin/bash -c "grep -vi pyqt /home/$MISO_USERNAME/peracotta/requirements.txt > /home/$MISO_USERNAME/peracotta/requirements32.txt"
  pip3 --quiet install -r /home/$MISO_USERNAME/peracotta/requirements32.txt
  rm -f /home/$MISO_USERNAME/peracotta/requirements32.txt
  echo "===== End incredible workaround for PyQt on 32 bit ====="
else
  # apt-get -qq autoremove -y python3-pyqt5 -o Dpkg::Use-Pty=false
  pip3 --quiet install -r /home/$MISO_USERNAME/peracotta/requirements.txt
fi

PERACOTTA_GENERATE_FILES=$(sudo -u $MISO_USERNAME find /home/$MISO_USERNAME/peracotta -name generate_files.sh -print -quit)
PERACOTTA_CLI=/home/$MISO_USERNAME/peracotta/peracruda
PERACOTTA_GUI=/home/$MISO_USERNAME/peracotta/peracotta

if [[ -f "$PERACOTTA_GENERATE_FILES" ]]; then
  sudo -u $MISO_USERNAME chmod +x "$PERACOTTA_GENERATE_FILES"
  ln -sf "$PERACOTTA_GENERATE_FILES" /usr/bin/generate_files
fi
if [[ -f "$PERACOTTA_CLI" ]]; then
  sudo -u $MISO_USERNAME chmod +x "$PERACOTTA_CLI"
fi
if [[ -f "$PERACOTTA_GUI" ]]; then
  sudo -u $MISO_USERNAME chmod +x "$PERACOTTA_GUI"
fi

echo "=== Add env to peracotta ==="
if [[ -f "./env.txt" ]]; then
  sudo -u $MISO_USERNAME cp ./env.txt /home/$MISO_USERNAME/peracotta/.env
else
  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "@                                                          @"
  echo "@                         WARNING                          @"
  echo "@                                                          @"
  echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "@                                                          @"
  echo "@   env.txt not found in weeedebian_files.                 @"
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

echo "=== XFCE configuration ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4
rsync -a --force ./xfce4 /home/$MISO_USERNAME/.config
chown weee: -R /home/$MISO_USERNAME/.config
sudo -u $MISO_USERNAME cp ./light-locker.desktop /home/$MISO_USERNAME/.config/autostart/light-locker.desktop
# sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/xfce4/desktop /home/$MISO_USERNAME/.config/xfce4/terminal

echo "=== Desktop shortcuts ==="
if [[ -d "/home/$MISO_USERNAME/limone" ]]; then
  sudo -u $MISO_USERNAME git -C /home/$MISO_USERNAME/limone pull --ff-only
else
  sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/limone
  sudo -u $MISO_USERNAME git clone https://github.com/WEEE-Open/limone.git /home/$MISO_USERNAME/limone
fi

for desktop_file in $(sudo -u $MISO_USERNAME find /home/$MISO_USERNAME/limone -name "*.desktop" -type f -printf "%f "); do
  sudo -u $MISO_USERNAME cp "/home/$MISO_USERNAME/limone/$desktop_file" "/home/$MISO_USERNAME/Desktop/$desktop_file"
  sudo -u $MISO_USERNAME chmod +x "/home/$MISO_USERNAME/Desktop/$desktop_file"
  sed -ri -e "s#Icon=(.*/)*([a-zA-Z0-9\-\.]+)#Icon=/home/$MISO_USERNAME/limone/\2#" "/home/$MISO_USERNAME/Desktop/$desktop_file"
done

sudo -u $MISO_USERNAME cp ./Peracotta.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./peracotta.png /home/$MISO_USERNAME/.config/peracotta.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/Peracotta.desktop

sudo -u $MISO_USERNAME cp ./PeracottaGUI.desktop /home/$MISO_USERNAME/Desktop
sudo -u $MISO_USERNAME cp ./peracotta_gui.png /home/$MISO_USERNAME/.config/peracotta_gui.png
sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/PeracottaGUI.desktop

echo "=== Pointerkeys thing ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME cp ./Pointerkeys.desktop /home/$MISO_USERNAME/.config/autostart/Pointerkeys.desktop
sudo -u $MISO_USERNAME cp ./pointerkeys.txt /home/$MISO_USERNAME/Desktop

echo "=== Autologin stuff ==="
cat << EOF > /etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user=$MISO_USERNAME
autologin-user-timeout=0
EOF
mkdir -p /etc/systemd/system/getty@.service.d
touch /etc/systemd/system/getty@.service.d/override.conf
printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=\n" >> /etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >> /etc/systemd/system/getty@.service.d/override.conf

echo "=== Final cleanup ==="
# Remove unused packages
apt-get -qq autoremove -y -o Dpkg::Use-Pty=false
# Clean the cache
apt-get -qq clean -y -o Dpkg::Use-Pty=false
rm -rf /var/lib/apt/lists/*

echo "=== Automatic configuration done ==="
#  read -p 'Open a shell in the chroot environment? [y/n] ' ans
#      if [[ $ans == "y" ]]; then
#          sudo -u $MISO_USERNAME /bin/bash
#      fi
