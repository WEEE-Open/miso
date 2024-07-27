echo "=== Prepare peracotta ==="
apt-get -qq -o Dpkg::Use-Pty=false install -y python3-pip pipx

sudo -u $MISO_USERNAME pipx ensurepath
sudo -u $MISO_USERNAME pipx install peracotta

echo '@reboot weee pipx upgrade peracotta' | sudo tee /etc/cron.d/peracotta_update

#sudo -u $MISO_USERNAME sh -c 'cd /home/$MISO_USERNAME/peracotta && python3 polkit.py'
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta # Ensure the dir exists
sudo -u $MISO_USERNAME cp ./features.json /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/features.json

echo "=== Add env to peracotta ==="
if [[ -z "$TARALLO_TOKEN" ]]; then
    missing="TARALLO_TOKEN"
fi
if [[ -z "$TARALLO_URL" ]]; then
    if [[ -z "$missing" ]]; then
        missing="TARALLO_URL"
    else
        missing="TARALLO_URL and TARALLO_TOKEN"
    fi
fi
if [[ -n "$missing" ]]; then
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "@                         WARNING                          @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "@   $missing not found in .env                             @"
    echo "@   You're missing out many great peracotta features!      @"
    echo "@   Check README for more info if you want to automate     @"
    echo "@   your life!                                             @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
else
    sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/.env <<EOF
    export TARALLO_URL=$TARALLO_URL
    export TARALLO_TOKEN=$TARALLO_TOKEN
EOF
fi