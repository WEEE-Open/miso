#!/bin/bash
# WEEEDebian creation script - a-porsia
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"
# For some reason (I checked and it's JLIVECD's fault, the F.A.L.C.E. is actually perfect asd) the script gets executed two times
# So it's necessary to ask whether the user wants to execute the script or not
read -p 'Execute martello.sh? [y/n]: ' ans
if [[ $ans == "y" ]]; then

	echo === Software installation ===
    sudo -H -u root /bin/bash -c 'apt update -y'
    sudo -H -u root /bin/bash -c 'apt install -y i2c-tools lshw smartmontools cifs-utils dmidecode pciutils gvfs-backends gsmartcontrol git'
    # Remove useless packages, courtesy of "wajig large". Cool command.
    # Also ispell is probably useless (if it's used only by LibreOffice)
    sudo -H -u root /bin/bash -c 'apt purge --auto-remove -y libreoffice libreoffice-core libreoffice-common gimp gimp-* aspell* hunspell* mythes* *sunpinyin* wpolish wnorwegian tegaki* task-thai task-thai-desktop xfonts-thai xiterm* task-khmer task-khmer-desktop fonts-khmeros khmerconverter'

    echo === Modules configuration ===
    if [[ -z `grep eeprom /etc/modules-load.d/eeprom.conf` ]]; then
        printf "eeprom\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep at24 /etc/modules-load.d/eeprom.conf` ]]; then
        printf "at24\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep weee /etc/passwd` ]]; then
        echo === User configuration ===
        if [[ -d "/home/weee" ]]; then
            rm -rf "/home/weee"
        fi
        # The encrypted password is "asd"
        useradd -m -G sudo -s /bin/bash weee -p "$6$cFAyjyCf$HiQKwzGvDioyYINpJ0kKmHEy6kXUlBJViMkd1ceizIpBFOftLVnjCuT6wvfLVhG7qnCo10q3vGzsaeyFIYHMO."
    fi

    echo === Sudo configuration ===
    sudo -H -u root cp /weeedebian_files/weee /etc/sudoers.d/weee

    echo === Prepare scriptino.sh ===
    sudo -H -u root chmod +x /weeedebian_files/scriptino.sh
    sudo -H -u root cp /weeedebian_files/scriptino.sh /usr/bin/scriptino

    echo === XFCE configuration ===
    sudo -H -u weee mkdir -p /home/weee/.config/xfce4
    sudo -H -u root rsync -a --force /weeedebian_files/xfce4 /home/weee/.config
    sudo -H -u root chown weee: -R /home/weee/.config

    echo === Link to tarallo ===
    sudo -H -u weee mkdir -p /home/weee/Desktop
    sudo -H -u weee cp /weeedebian_files/Tarallo.desktop /home/weee/Desktop
    sudo -H -u weee chmod +x /home/weee/Desktop/Tarallo.desktop

    echo === Keymap configuration ===
    sudo -H -u root echo "KEYMAP=it" > /etc/vconsole.conf
    # Probably not needed:
    # sudo -H -u root echo "LANG=it_IT.UTF-8" > /etc/locale.conf
    # 00-keyboard.conf can be managed by localectl. In fact, this is one of such files produced by localectl.
    mkdir -p /etc/X11/xorg.conf.d
    sudo -H -u root cp /weeedebian_files/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

    echo === Autologin stuff ===
    sudo -H -u root mkdir -p /etc/systemd/system/getty@.service.d
    sudo -H -u root touch /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "[Service]\n" > /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=\n" >> /etc/systemd/system/getty@.service.d/override.conf
    sudo -H -u root printf "ExecStart=-/sbin/agetty --noissue --autologin weee %%I $TERM" >> /etc/systemd/system/getty@.service.d/override.conf

	echo === Automatic configuration done ===
    # Starts an xfce4 session if you need to modify xfce4 settings for user weee
    read -p 'Start xfce4 (Press Ctrl+C in this terminal to close it) [y/n]?: ' ans
        if [[ $ans == "y" ]]; then
            sudo -H -u weee /bin/bash -c 'xfce4-panel'
        fi
else
    exit
fi
