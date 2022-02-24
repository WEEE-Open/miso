#!/bin/bash

# WEEEDebian creation script - a-porsia et al
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"

runuser -l weee -c 'rm /home/weee/.bash_history  >/dev/null 2>/dev/null'
rm /root/.bash_history >/dev/null 2>/dev/null

echo "=== Keymap configuration ==="
echo "KEYMAP=it" > /etc/vconsole.conf
# Probably not needed:
# echo "LANG=it_IT.UTF-8" > /etc/locale.conf
# 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
mkdir -p /etc/X11/xorg.conf.d
cp /weeedebian_files/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

echo "=== Locale configuration ==="
cp /weeedebian_files/locale.gen /etc/locale.gen
cp /weeedebian_files/locale.conf /etc/locale.conf
locale-gen
. /etc/locale.conf
locale

echo "=== Software installation ==="
# Remove useless packages, courtesy of "wajig large". Cool command.
# Do not remove mousepad, it removes xfce-goodies too
#/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
# Upgrade and install useful packages
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get update -y'
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
# libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y xfce-goodies'
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y pciutils i2c-tools lshw mesa-utils smartmontools cifs-utils dmidecode gvfs-backends gsmartcontrol git gparted openssh-server zsh libxkbcommon-x11-0 geany curl wget iputils-tracepath traceroute'

echo "=== SSH daemon configuration ==="
cp /weeedebian_files/sshd_config /etc/ssh/sshd_config

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
#        rm -rf "/home/weee"
#    fi
#    useradd -m -G sudo -s /bin/zsh weee
#    # The -p parameter is silently ignored for some reason:
#    # -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
#    # This ALSO does not work:
#    #echo "weee:asd" | chpasswd
#    # So...
#fi
#sed -i 's#weee:.*#weee:$6$1JlXeMWKid5Uf4ty$ewHoPm6P9hK8Lm4KW21YMCQju435r4SyWu7S0mwJZ5360SU1L2NKLU5YuQAzidRDmh/R7lIjxR/G8Pd8Yj/Wo0:18214:0:99999:7:::#' /etc/shadow
chsh -s /bin/zsh root
chsh -s /bin/zsh weee
runuser -l weee -c 'curl -L -o /home/weee/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc'
cp /home/weee/.zshrc /root/.zshrc

echo "=== Sudo configuration ==="
cp /weeedebian_files/weee /etc/sudoers.d/weee

echo "=== DNS configuration ==="
cp /weeedebian_files/resolv.conf /etc/resolv.conf
cp /weeedebian_files/resolved.conf /etc/systemd/resolved.conf
rm -f /var/run/NetworkManager/* 2>/dev/null

echo "=== NTP configuration ==="
systemctl enable systemd-timesyncd
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

echo "=== Top configuration ==="
cp /weeedebian_files/toprc /root/.toprc
runuser -l weee -c 'cp /weeedebian_files/toprc /home/weee/.toprc'

echo "=== Prepare peracotta ==="
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt install -y python3-pip'
# PyQt > 5.14.0 requires an EXTREMELY RECENT version of pip,
# on the most bleeding of all bleeding edges
pip3 install --quiet --upgrade pip

cp /weeedebian_files/peracotta_update /etc/cron.d/peracotta_update

if [[ -d "/home/weee/peracotta" ]]; then
  rm -rf /home/weee/peracotta
  #runuser -l weee -c 'git -C /home/weee/peracotta pull'
fi
#else
runuser -l weee -c 'mkdir -p /home/weee/peracotta'
runuser -l weee -c 'git clone https://github.com/WEEE-Open/peracotta.git /home/weee/peracotta'
#fi

#runuser -l weee -c 'sh -c 'cd /home/weee/peracotta && python3 polkit.py''
runuser -l weee -c 'cp /weeedebian_files/features.json /home/weee/peracotta/features.json'

if [[ "x$(dpkg --print-architecture)" == "xi386" ]]; then
  echo ""===== Begin incredible workaround for PyQt on 32 bit =====""
  /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt install -y python3-pyqt5'
  runuser -l weee -c '/bin/bash -c 'grep -vi "pyqt" /home/weee/peracotta/requirements.txt > /home/weee/peracotta/requirements32.txt''
  pip3 --quiet install -r /home/weee/peracotta/requirements32.txt
  rm -f /home/weee/peracotta/requirements32.txt
  echo ""===== End incredible workaround for PyQt on 32 bit =====""
else
  /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt autoremove -y python3-pyqt5'
  pip3 --quiet install -r /home/weee/peracotta/requirements.txt
fi

PERACOTTA_GENERATE_FILES=$(runuser -l weee -c 'find /home/weee/peracotta -name "generate_files*" -print -quit)'
PERACOTTA_MAIN=$(runuser -l weee -c 'find /home/weee/peracotta -name "peracruda" -print -quit)'
PERACOTTA_MAIN_WITH_GUI=$(runuser -l weee -c 'find /home/weee/peracotta -name "peracotta" -print -quit)'

if [[ -f "$PERACOTTA_GENERATE_FILES" ]]; then
  runuser -l weee -c 'chmod +x "$PERACOTTA_GENERATE_FILES"'
  ln -s "$PERACOTTA_GENERATE_FILES" /usr/bin/generate_files
fi
if [[ -f "$PERACOTTA_MAIN" ]]; then
  runuser -l weee -c 'chmod +x "$PERACOTTA_MAIN"'
fi
if [[ -f "$PERACOTTA_MAIN_WITH_GUI" ]]; then
  runuser -l weee -c 'chmod +x "$PERACOTTA_MAIN_WITH_GUI"'
fi

echo "=== Add env to peracotta ==="
if [[ -f "/weeedebian_files/env.txt" ]]; then
  runuser -l weee -c 'cp /weeedebian_files/env.txt /home/weee/peracotta/.env'
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
cp /weeedebian_files/s.sh /usr/sbin/s.sh
chmod +x /usr/sbin/s.sh
runuser -l weee -c 'cp /weeedebian_files/ssh.desktop /home/weee/Desktop'
runuser -l weee -c 'chmod +x /home/weee/Desktop/ssh.desktop'

echo "=== XFCE configuration ==="
runuser -l weee -c 'mkdir -p /home/weee/.config/xfce4'
rsync -a --force /weeedebian_files/xfce4 /home/weee/.config
chown weee: -R /home/weee/.config
runuser -l weee -c 'mkdir /home/weee/.config/xfce4/desktop /home/weee/.config/xfce4/terminal'

echo "=== Desktop shortcuts ==="
if [[ -d "/home/weee/limone" ]]; then
  runuser -l weee -c 'git -C /home/weee/limone pull'
else
  runuser -l weee -c 'mkdir -p /home/weee/limone'
  runuser -l weee -c 'git clone https://github.com/WEEE-Open/limone.git /home/weee/limone'
fi

runuser -l weee -c 'mkdir -p /home/weee/Desktop'

for desktop_file in $(runuser -l weee -c 'find /home/weee/limone -name "*.desktop" -type f -printf "%f "); do'
  runuser -l weee -c 'cp "/home/weee/limone/$desktop_file" "/home/weee/Desktop/$desktop_file"'
  runuser -l weee -c 'chmod +x "/home/weee/Desktop/$desktop_file"'
  sed -ri -e "s#Icon=(.*/)*([a-zA-Z0-9\-\.]+)#Icon=/home/weee/limone/\2#" "/home/weee/Desktop/$desktop_file"
done

runuser -l weee -c 'cp /weeedebian_files/Peracotta.desktop /home/weee/Desktop'
runuser -l weee -c 'cp /weeedebian_files/peracotta.png /home/weee/.config/peracotta.png'
runuser -l weee -c 'chmod +x /home/weee/Desktop/Peracotta.desktop'

runuser -l weee -c 'cp /weeedebian_files/PeracottaGUI.desktop /home/weee/Desktop'
runuser -l weee -c 'cp /weeedebian_files/peracotta_gui.png /home/weee/.config/peracotta_gui.png'
runuser -l weee -c 'chmod +x /home/weee/Desktop/PeracottaGUI.desktop'

echo "=== Pointerkeys thing ==="
runuser -l weee -c 'mkdir -p /home/weee/.config/autostart'
runuser -l weee -c 'cp /weeedebian_files/Pointerkeys.desktop /home/weee/.config/autostart/Pointerkeys.desktop'
runuser -l weee -c 'cp /weeedebian_files/pointerkeys.txt /home/weee/Desktop'

echo "=== Autologin stuff ==="
cp /weeedebian_files/lightdm.conf /etc/lightdm/lightdm.conf
mkdir -p /etc/systemd/system/getty@.service.d
touch /etc/systemd/system/getty@.service.d/override.conf
printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=\n" >> /etc/systemd/system/getty@.service.d/override.conf
printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >> /etc/systemd/system/getty@.service.d/override.conf

echo "=== Final cleanup ==="
# Remove unused packages
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get autoremove -y'
# Clean the cache
/bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get clean -y'

# TODO: restore?
#  echo "=== Set hostname ==="
#  echo "weeedebian" > /etc/hostname
#
#  echo "=== Automatic configuration done ==="
#  read -p 'Open a shell in the chroot environment? [y/n] ' ans
#      if [[ $ans == "y" ]]; then
#          runuser -l weee -c '/bin/bash'
#      fi