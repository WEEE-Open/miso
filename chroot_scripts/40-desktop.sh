echo "=== Desktop shortcuts ==="
mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open
for file in ./desktop/*.desktop; do
    sudo -u $MISO_USERNAME cp $file /home/$MISO_USERNAME/Desktop
    file=$(basename -s .desktop $file)
    sudo -u $MISO_USERNAME cp ./img/$file.png /home/$MISO_USERNAME/.config/WEEE\ Open/
    sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/$file.desktop
    f=/home/$MISO_USERNAME/Desktop/$file.desktop
    gio set -t string $f metadata::xfce-exe-checksum "$(sha256sum $f | awk '{print $1}')"
    #su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Tarallo.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/Tarallo.desktop | awk '{print $1}')"
done
