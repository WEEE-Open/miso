#!/bin/bash

echo "=== Pointerkeys thing ==="
sudo -u $MISO_USERNAME mkdir -p /home/$MISO_USERNAME/.config/autostart
sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/.config/autostart/Pointerkeys.desktop <<EOF >/dev/null
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Pointerkeys
Comment=Move cursor with numpad
Exec=setxkbmap -option keypad:pointerkeys
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF

sudo -u $MISO_USERNAME tee /home/$MISO_USERNAME/Desktop/pointerkeys.txt <<EOF >/dev/null
=== Controlling your mouse pointer with the keyboard ===

Hold shift and press num lock to enable this feature.

Use number keys on the keypad to navigate (or fn+number keys on laptops).

To select a mouse button:
/  left mouse button (press twice for double, thrice for triple click)
*  middle mouse button
-  right mouse button

Then press:
5 or +    actually click with the selected button
0 or Ins  press and hold (to start dragging files)
. or Del  release the button (to stop dragging)
EOF
