#!/bin/bash

echo "=== Locale configuration ==="
tee /etc/locale.gen <<EOF >/dev/null
it_IT.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
tee /etc/locale.conf <<EOF >/dev/null
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_CTYPE=it_IT.UTF-8
LC_NUMERIC=it_IT.UTF-8
LC_TIME=it_IT.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=it_IT.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=it_IT.UTF-8
LC_NAME=it_IT.UTF-8
LC_ADDRESS=it_IT.UTF-8
LC_TELEPHONE=it_IT.UTF-8
LC_MEASUREMENT=it_IT.UTF-8
LC_IDENTIFICATION=it_IT.UTF-8
EOF

locale-gen
update-locale

echo "=== Keymap configuration ==="
# Needed for sure on Debian 11:
tee /etc/default/keyboard <<EOF >/dev/null
XKBMODEL="pc105"
XKBLAYOUT="it,us"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF
