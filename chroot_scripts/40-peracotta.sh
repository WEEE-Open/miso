echo "=== Prepare peracotta ==="
apt-get -qq -o Dpkg::Use-Pty=false install -y python3-pip pipx

sudo -u $MISO_USERNAME pipx ensurepath >/dev/null
sudo -u $MISO_USERNAME pipx install peracotta >/dev/null

echo '@reboot weee pipx upgrade peracotta' | sudo tee /etc/cron.d/peracotta_update

#sudo -u $MISO_USERNAME sh -c 'cd /home/$MISO_USERNAME/peracotta && python3 polkit.py'
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta # Ensure the dir exists
sudo -u $MISO_USERNAME cp ./resources/features.json /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/features.json

sudo -u $MISO_USERNAME cp ./resources/peracotta_config.toml /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/config.toml

echo "=== Add env to peracotta ==="
if [[ -z "$TARALLO_TOKEN" ]]; then
    missing="@   TARALLO_TOKEN not found in .env                        @"
fi
if [[ -z "$TARALLO_URL" ]]; then
    if [[ -z "$missing" ]]; then
        missing="@   TARALLO_URL not found in .env                          @"
    else
        missing="@   TARALLO_URL and TARALLO_TOKEN not found in .env        @"
    fi
fi
if [[ -n "$missing" ]]; then
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "@                         WARNING                          @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@                                                          @"
    echo "$missing"
    echo "@   You're missing out many great peracotta features!      @"
    echo "@   Check README for more info if you want to automate     @"
    echo "@   your life!                                             @"
    echo "@                                                          @"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
else
    sudo -u $MISO_USERNAME tee -a /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/config.toml <<EOF
TARALLO_URL = "$TARALLO_URL"
TARALLO_TOKEN = "$TARALLO_TOKEN"
EOF
fi

sudo -u $MISO_USERNAME tee -a /home/$MISO_USERNAME/.config/WEEE\ Open/peracotta/config.toml <<EOF
AUTOMATIC_REPORT_ERRORS = $PERACOTTA_AUTOMATIC_REPORT_ERRORS
REPORT_URL = "$PERACOTTA_REPORT_URL"
EOF