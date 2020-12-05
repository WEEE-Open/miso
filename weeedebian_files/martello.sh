#!/bin/bash
# WEEEDebian creation script - a-porsia
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"
# For some reason (I checked and it's JLIVECD's fault, the F.A.L.C.E. is actually perfect asd) the script gets executed two times
# So it's necessary to ask whether the user wants to execute the script or not
read -p 'Execute martello.sh? [y/n]: ' ans
if [[ $ans == "y" ]]; then
    echo === Keymap configuration ===
    sudo -H -u root echo "KEYMAP=it" > /etc/vconsole.conf
    # Probably not needed:
    # sudo -H -u root echo "LANG=it_IT.UTF-8" > /etc/locale.conf
    # 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
    mkdir -p /etc/X11/xorg.conf.d
    sudo -H -u root cp /weeedebian_files/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

    echo === Locale configuration ===
    sudo -H -u root cp /weeedebian_files/locale.gen /etc/locale.gen
    sudo -H -u root cp /weeedebian_files/locale.conf /etc/locale.conf
    sudo -H -u root locale-gen
    . /etc/locale.conf
    locale

    echo === Software installation ===
    # Remove useless packages, courtesy of "wajig large". Cool command.
    # Do not remove mousepad, it removes xfce-goodies too
    sudo -H -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt purge --auto-remove -y libreoffice libreoffice-core libreoffice-common ispell* gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'
    # Upgrade and install useful packages
    sudo -H -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt update -y'
    sudo -H -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt upgrade -y'
    # libxkbcommon-x11-0 may be not needed (see Add library to installation if needed #28)
    sudo -H -u root /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt install -y pciutils i2c-tools lshw mesa-utils smartmontools cifs-utils dmidecode gvfs-backends gsmartcontrol git gparted openssh-server zsh libxkbcommon-x11-0 geany'

    echo === SSH daemon configuration ===
    sudo -H -u root cp /weeedebian_files/sshd_config /etc/ssh/sshd_config

    echo === Modules configuration ===
    if [[ ! -f "/etc/modules-load.d/eeprom.conf" ]]; then
      touch /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep eeprom /etc/modules-load.d/eeprom.conf` ]]; then
        printf "eeprom\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep at24 /etc/modules-load.d/eeprom.conf` ]]; then
        printf "at24\n" > /etc/modules-load.d/eeprom.conf
    fi

    echo === User configuration ===
    if [[ -z `grep weee /etc/passwd` ]]; then
        if [[ -d "/home/weee" ]]; then
            sudo -H -u root rm -rf "/home/weee"
        fi
        sudo -H -u root useradd -m -G sudo -s /bin/zsh weee
        # The -p parameter is silently ignored for some reason:
        # -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
        # This ALSO does not work:
        #echo "weee:asd" | sudo -H -u root chpasswd
        # So...
    fi
    sudo -H -u root sed -i '/weee:.+\weee:$6$1JlXeMWKid5Uf4ty$ewHoPm6P9hK8Lm4KW21YMCQju435r4SyWu7S0mwJZ5360SU1L2NKLU5YuQAzidRDmh/R7lIjxR/G8Pd8Yj/Wo0:18214:0:99999:7:::' /etc/shadow
    sudo -H -u root chsh -s /bin/zsh weee
    if [[ -f "/home/weee/.zshrc" ]]; then
      sudo -H -u weee wget -O /home/weee/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
    fi
    if [[ -f "/root/.zshrc" ]]; then
      sudo -H -u root cp /home/weee/.zshrc /root/.zshrc
    fi
    echo === Sudo configuration ===
    sudo -H -u root cp /weeedebian_files/weee /etc/sudoers.d/weee

    echo === Top configuration ===
    sudo -H -u root cp /weeedebian_files/toprc /root/.toprc
    sudo -H -u weee cp /weeedebian_files/toprc /home/weee/.toprc

    echo === Prepare peracotta ===
    sudo -H -u root /bin/bash -c 'apt install -y python3-pip'
    # PyQt > 5.14.0 requires an EXTREMELY RECENT version of pip,
    # on the most bleeding of all bleeding edges
    sudo -H -u root pip3 install --upgrade pip

    if [[ -d "/home/weee/peracotta" ]]; then
      sudo -H -u weee git -C /home/weee/peracotta pull
    else
      sudo -H -u weee mkdir -p /home/weee/peracotta
      sudo -H -u weee git clone https://github.com/WEEE-Open/peracotta.git /home/weee/peracotta
    fi
    sudo -H -u weee chmod +x /home/weee/peracotta/generate_files.sh
    # PyQt 5 is currently impossible to build, due to a very simple error with a
    # very simple fix (upgrade pip to 20.2 or above) which simply does not work at
    # all and does not solve anything (pip is already at 20.4.2), so it's simply
    # impossible to install requirements. That's it. The end.
    # sudo -H -u root pip3 install -r /home/weee/peracotta/requirements.txt
    # At least the apt package works correctly, somehow the Debian maintainers
    # managed to build it:
    sudo -H -u root /bin/bash -c 'apt install -y python3-pyqt5'

    if [[ ! -f "/usr/bin/generate_files.sh" ]]; then
      sudo -H -u root ln -s /home/weee/peracotta/generate_files.sh /usr/bin/generate_files.sh
    fi
    if [[ ! -f "/usr/bin/generate_files" ]]; then
      sudo -H -u root ln -s /home/weee/peracotta/generate_files.sh /usr/bin/generate_files
    fi

    echo === XFCE configuration ===
    sudo -H -u weee mkdir -p /home/weee/.config/xfce4
    sudo -H -u root rsync -a --force /weeedebian_files/xfce4 /home/weee/.config
    sudo -H -u root chown weee: -R /home/weee/.config

    echo === Link to tarallo ===
    sudo -H -u weee mkdir -p /home/weee/Desktop
    sudo -H -u weee cp /weeedebian_files/Tarallo.desktop /home/weee/Desktop
    sudo -H -u weee cp /weeedebian_files/tarallo.png /home/weee/.config/tarallo.png
    sudo -H -u weee chmod +x /home/weee/Desktop/Tarallo.desktop

    echo === Pointerkeys thing ===
    sudo -H -u weee mkdir -p /home/weee/.config/autostart
    sudo -H -u weee cp /weeedebian_files/Pointerkeys.desktop /home/weee/.config/autostart/Pointerkeys.desktop
    sudo -H -u weee cp /weeedebian_files/pointerkeys.txt /home/weee/Desktop

    echo === Autologin stuff ===
    sudo -H -u root cp /weeedebian_files/lightdm.conf /etc/lightdm/lightdm.conf
    sudo -H -u root mkdir -p /etc/systemd/system/getty@.service.d
    sudo -H -u root touch /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=\n" >> /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >> /etc/systemd/system/getty@.service.d/override.conf

    echo === Set hostname ===
    echo "weeedebian" > /etc/hostname

    echo === Automatic configuration done ===
    read -p 'Open a shell in the chroot environment? [y/n] ' ans
        if [[ $ans == "y" ]]; then
            sudo -H -u weee /bin/bash
        fi
else
    exit
fi
