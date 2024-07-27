echo "=== Desktop shortcuts ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open
for file in ./desktop/*.desktop; do
    sudo -u $MISO_USERNAME cp $file /home/$MISO_USERNAME/Desktop
    file=$(basename -s .desktop $file)
    sudo -u $MISO_USERNAME cp ./img/$file.png /home/$MISO_USERNAME/.config/WEEE\ Open/
    sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/$file.desktop
done
sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/autostart/trust_desktop_shortcuts.desktop <<EOF >/dev/null
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Trust Desktop Shortcuts
Comment=Automatically trust all the .desktop files on the desktop
Exec=bash -c "for file in /home/$MISO_USERNAME/Desktop/*.desktop; do gio set -t string \\\$file metadata::xfce-exe-checksum \\\$(sha256sum \\\$file | awk '{print \\\$1}'); done"
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF
#sudo tee /etc/cron.d/desktop_shortcuts <<EOF >/dev/null
#@reboot weee for file in /home/$MISO_USERNAME/Desktop/*.desktop; do gio set -t string \$file metadata::xfce-exe-checksum "\$(sha256sum \$file | awk '{print \$1}')"; done
#EOF
#sudo tee /etc/cron.d/desktop_shortcuts <<EOF >/dev/null
#@reboot weee export XDG_DATA_DIRS=\$XDG_DATA_DIRS:/home/$MISO_USERNAME/Desktop
#EOF
