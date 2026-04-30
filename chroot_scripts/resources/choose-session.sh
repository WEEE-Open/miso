#!/bin/bash

if [ "$MISO_FORCE_SESSION" = "wayland" ]; then
    USE_WAYLAND=true
elif [ "$MISO_FORCE_SESSION" = "x11" ]; then
    USE_WAYLAND=false
else
    HAS_RENDER_NODE=$(ls /dev/dri/renderD* 2>/dev/null)
    CURRENT_DRIVER=$(basename $(readlink /sys/class/drm/card0/device/driver 2>/dev/null) 2>/dev/null)
    IS_GENERIC_DRIVER=false
    [[ "$CURRENT_DRIVER" == "vesa" || "$CURRENT_DRIVER" == "efifb" || -z "$CURRENT_DRIVER" ]] && IS_GENERIC_DRIVER=true

    USE_WAYLAND=false
    # verifica presenza del binario plasma-wayland
    if [ -n "$HAS_RENDER_NODE" ] && [ "$IS_GENERIC_DRIVER" = false ] && [ -x /usr/bin/startplasma-wayland ]; then
        USE_WAYLAND=true
    fi
fi

if [ "$USE_WAYLAND" = true ]; then
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=KDE
    exec startplasma-wayland && exit 0
fi

# --- FALLBACK X11 ---
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
exec startplasma-x11
