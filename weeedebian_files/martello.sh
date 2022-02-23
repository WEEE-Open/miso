#!/bin/bash
# WEEEDebian creation script - a-porsia
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"

sudo -u weee rm /home/weee/.bash_history  >/dev/null 2>/dev/null
sudo -u root rm /root/.bash_history >/dev/null 2>/dev/null

echo "=== Keymap configuration ==="
sudo -u root echo "KEYMAP=it" > /etc/vconsole.conf
# Probably not needed:
# sudo -u root echo "LANG=it_IT.UTF-8" > /etc/locale.conf
# 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
mkdir -p /etc/X11/xorg.conf.d
sudo -u root cp /weeedebian_files/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

echo "=== Locale configuration ==="
sudo -u root cp /weeedebian_files/locale.gen /etc/locale.gen
sudo -u root cp /weeedebian_files/locale.conf /etc/locale.conf
sudo -u root locale-gen
. /etc/locale.conf
locale

echo "=== Software installation ==="
# Remove useless packages, courtesy of "wajig large". Cool command.
# Do not remove mousepad, it removes xfce-goodies too
#sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
# Upgrade and install useful packages
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get update -y'
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y xfce-goodies'
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y pciutils i2c-tools lshw mesa-utils smartmontools cifs-utils dmidecode gvfs-backends gsmartcontrol git gparted openssh-server zsh libxkbcommon-x11-0 geany curl wget iputils-tracepath traceroute'

echo "=== SSH daemon configuration ==="
sudo -u root cp /weeedebian_files/sshd_config /etc/ssh/sshd_config

echo "=== Modules configuration ==="
if [[ ! -f "/etc/modules-load.d/eeprom.conf" ]]; then
  touch /etc/modules-load.d/eeprom.conf
fi
if [[ -z `grep eeprom /etc/modules-load.d/eeprom.conf` ]]; then
    printf "eeprom\n" > /etc/modules-load.d/eeprom.conf
fi
if [[ -z `grep at24 /etc/modules-load.d/eeprom.conf` ]]; then
    printf "at24\n" > /etc/modules-load.d/eeprom.conf
fi

echo "=== User configuration ==="
# TODO: restore?
#if [[ -z `grep weee /etc/passwd` ]]; then
#    if [[ -d "/home/weee" ]]; then
#        sudo -u root rm -rf "/home/weee"
#    fi
#    sudo -u root useradd -m -G sudo -s /bin/zsh weee
#    # The -p parameter is silently ignored for some reason:
#    # -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
#    # This ALSO does not work:
#    #echo "weee:asd" | sudo -u root chpasswd
#    # So...
#fi
#sudo -u root sed -i 's#weee:.*#weee:$6$1JlXeMWKid5Uf4ty$ewHoPm6P9hK8Lm4KW21YMCQju435r4SyWu7S0mwJZ5360SU1L2NKLU5YuQAzidRDmh/R7lIjxR/G8Pd8Yj/Wo0:18214:0:99999:7:::#' /etc/shadow
sudo -u root chsh -s /bin/zsh root
sudo -u root chsh -s /bin/zsh weee
sudo -u weee curl -L -o /home/weee/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
sudo -u root cp /home/weee/.zshrc /root/.zshrc

echo "=== Sudo configuration ==="
sudo -u root cp /weeedebian_files/weee /etc/sudoers.d/weee

echo "=== DNS configuration ==="
sudo -u root cp /weeedebian_files/resolv.conf /etc/resolv.conf
sudo -u root cp /weeedebian_files/resolved.conf /etc/systemd/resolved.conf
sudo -u root rm -f /var/run/NetworkManager/* 2>/dev/null

echo "=== NTP configuration ==="
sudo -u root systemctl enable systemd-timesyncd
sudo -u root rm -f /etc/localtime
sudo -u root ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

echo "=== Top configuration ==="
sudo -u root cp /weeedebian_files/toprc /root/.toprc
sudo -u weee cp /weeedebian_files/toprc /home/weee/.toprc

echo "=== Prepare peracotta ==="
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt install -y python3-pip'
# PyQt > 5.14.0 requires an EXTREMELY RECENT version of pip,
# on the most bleeding of all bleeding edges
sudo -u root pip3 install --quiet --upgrade pip

sudo -u root cp /weeedebian_files/peracotta_update /etc/cron.d/peracotta_update

if [[ -d "/home/weee/peracotta" ]]; then
  sudo -u root rm -rf /home/weee/peracotta
  #sudo -u weee git -C /home/weee/peracotta pull
fi
#else
sudo -u weee mkdir -p /home/weee/peracotta
sudo -u weee git clone https://github.com/WEEE-Open/peracotta.git /home/weee/peracotta
#fi

#sudo -u weee sh -c 'cd /home/weee/peracotta && python3 polkit.py'
sudo -u weee cp /weeedebian_files/features.json /home/weee/peracotta/features.json

if [[ "x$(dpkg --print-architecture)" == "xi386" ]]; then
  echo ""===== Begin incredible workaround for PyQt on 32 bit =====""
  sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt install -y python3-pyqt5'
  sudo -u weee /bin/bash -c 'grep -vi "pyqt" /home/weee/peracotta/requirements.txt > /home/weee/peracotta/requirements32.txt'
  sudo -u root pip3 --quiet install -r /home/weee/peracotta/requirements32.txt
  sudo -u root rm -f /home/weee/peracotta/requirements32.txt
  echo ""===== End incredible workaround for PyQt on 32 bit =====""
else
  sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt autoremove -y python3-pyqt5'
  sudo -u root pip3 --quiet install -r /home/weee/peracotta/requirements.txt
fi

PERACOTTA_GENERATE_FILES=$(sudo -u weee find /home/weee/peracotta -name "generate_files*" -print -quit)
PERACOTTA_MAIN=$(sudo -u weee find /home/weee/peracotta -name "peracruda" -print -quit)
PERACOTTA_MAIN_WITH_GUI=$(sudo -u weee find /home/weee/peracotta -name "peracotta" -print -quit)

if [[ -f "$PERACOTTA_GENERATE_FILES" ]]; then
  sudo -u weee chmod +x "$PERACOTTA_GENERATE_FILES"
  sudo -u root ln -s "$PERACOTTA_GENERATE_FILES" /usr/bin/generate_files
fi
if [[ -f "$PERACOTTA_MAIN" ]]; then
  sudo -u weee chmod +x "$PERACOTTA_MAIN"
fi
if [[ -f "$PERACOTTA_MAIN_WITH_GUI" ]]; then
  sudo -u weee chmod +x "$PERACOTTA_MAIN_WITH_GUI"
fi

echo "=== Add env to peracotta ==="
if [[ -f "/weeedebian_files/env.txt" ]]; then
  sudo -u weee cp /weeedebian_files/env.txt /home/weee/peracotta/.env
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
sudo -u root cp /weeedebian_files/s.sh /usr/sbin/s.sh
sudo -u root chmod +x /usr/sbin/s.sh
sudo -u weee cp /weeedebian_files/ssh.desktop /home/weee/Desktop
sudo -u weee chmod +x /home/weee/Desktop/ssh.desktop

echo "=== XFCE configuration ==="
sudo -u weee mkdir -p /home/weee/.config/xfce4
sudo -u root rsync -a --force /weeedebian_files/xfce4 /home/weee/.config
sudo -u root chown weee: -R /home/weee/.config

echo "=== Desktop shortcuts ==="
if [[ -d "/home/weee/limone" ]]; then
  sudo -u weee git -C /home/weee/limone pull
else
  sudo -u weee mkdir -p /home/weee/limone
  sudo -u weee git clone https://github.com/WEEE-Open/limone.git /home/weee/limone
fi

sudo -u weee mkdir -p /home/weee/Desktop

for desktop_file in $(sudo -u weee find /home/weee/limone -name "*.desktop" -type f -printf "%f "); do
  sudo -u weee cp "/home/weee/limone/$desktop_file" "/home/weee/Desktop/$desktop_file"
  sudo -u weee chmod +x "/home/weee/Desktop/$desktop_file"
  sed -ri -e "s#Icon=(.*/)*([a-zA-Z0-9\-\.]+)#Icon=/home/weee/limone/\2#" "/home/weee/Desktop/$desktop_file"
done

sudo -u weee cp /weeedebian_files/Peracotta.desktop /home/weee/Desktop
sudo -u weee cp /weeedebian_files/peracotta.png /home/weee/.config/peracotta.png
sudo -u weee chmod +x /home/weee/Desktop/Peracotta.desktop

sudo -u weee cp /weeedebian_files/PeracottaGUI.desktop /home/weee/Desktop
sudo -u weee cp /weeedebian_files/peracotta_gui.png /home/weee/.config/peracotta_gui.png
sudo -u weee chmod +x /home/weee/Desktop/PeracottaGUI.desktop

echo "=== Pointerkeys thing ==="
sudo -u weee mkdir -p /home/weee/.config/autostart
sudo -u weee cp /weeedebian_files/Pointerkeys.desktop /home/weee/.config/autostart/Pointerkeys.desktop
sudo -u weee cp /weeedebian_files/pointerkeys.txt /home/weee/Desktop

echo "=== Autologin stuff ==="
sudo -u root cp /weeedebian_files/lightdm.conf /etc/lightdm/lightdm.conf
sudo -u root mkdir -p /etc/systemd/system/getty@.service.d
sudo -u root touch /etc/systemd/system/getty@.service.d/override.conf
sudo -u root printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
sudo -u root printf "ExecStart=\n" >> /etc/systemd/system/getty@.service.d/override.conf
sudo -u root printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >> /etc/systemd/system/getty@.service.d/override.conf

echo "=== Final cleanup ==="
# Remove unused packages
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get autoremove -y'
# Clean the cache
sudo -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get clean -y'

# TODO: restore?
#  echo "=== Set hostname ==="
#  echo "weeedebian" > /etc/hostname
#
#  echo "=== Automatic configuration done ==="
#  read -p 'Open a shell in the chroot environment? [y/n] ' ans
#      if [[ $ans == "y" ]]; then
#          sudo -u weee /bin/bash
#      fi
