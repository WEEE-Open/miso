#!/bin/bash
# WEEEDebian creation script - a-porsia
export PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"
# For some reason (I checked and it's JLIVECD's fault, the F.A.L.C.E. is actually perfect asd) the script gets executed two times
# So it's necessary to ask whether the user wants to execute the script or not
read -p 'Execute martello.sh? [y/n]: ' ans
if [[ $ans == "y" ]]; then

    sudo -H -u root /bin/bash -c 'apt update -y && apt install -y i2c-tools lshw smartmontools cifs-utils dmidecode pciutils gvfs-backends gsmartcontrol git'
    if [[ -z `grep eeprom /etc/modules-load.d/eeprom.conf` ]]; then
        printf "eeprom\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep at24 /etc/modules-load.d/eeprom.conf` ]]; then
        printf "at24\n" > /etc/modules-load.d/eeprom.conf
    fi
    if [[ -z `grep weee /etc/passwd` ]]; then
        if [[ -d "/home/weee" ]]; then
            rm -rf "/home/weee"
        fi
        adduser weee
        adduser weee sudo
        passwd weee
    fi

    echo === Prepare scriptino.sh ===
    sudo -H -u root chmod +x /weeedebian_files/scriptino.sh
    sudo -H -u root cp /weeedebian_files/scriptino.sh /usr/bin/scriptino

    echo === XFCE configuration ===
    sudo -H -u root rsync -a -r --force /weeedebian_files/xfce4 /home/weee/.config/xfce4

    echo === Link to tarallo ===
    sudo -H -u weee mkdir -p /home/weee/Desktop
    sudo -H -u weee cp /weeedebian_files/Tarallo.desktop /home/weee/Desktop

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
# TODO: add a link to Tarallo
