echo "=== Desktop shortcuts ==="
for file in ./desktop/*.desktop; do
    echo $file
    sudo -u $MISO_USERNAME cp $file /home/$MISO_USERNAME/Desktop
    #sudo -u $MISO_USERNAME cp $file /home/$MISO_USERNAME/.config/WEEE\ Open/
    sudo -u $MISO_USERNAME chmod +x /home/$MISO_USERNAME/Desktop/$(basename $file)
    su - $MISO_USERNAME -c "gio set -t string /home/$MISO_USERNAME/Desktop/Tarallo.desktop metadata::xfce-exe-checksum $(sha256sum /home/$MISO_USERNAME/Desktop/Tarallo.desktop | awk '{print $1}')"
done
