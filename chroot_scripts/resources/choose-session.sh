#!/bin/bash
# Gemini Generated :)

if [ "$MISO_FORCE_SESSION" = "wayland" ]; then
    USE_WAYLAND=true
elif [ "$MISO_FORCE_SESSION" = "x11" ]; then
    USE_WAYLAND=false
else
    # 1. Verifica se esiste un render node (fondamentale per Wayland/Mesa)
    HAS_RENDER_NODE=$(ls /dev/dri/renderD* 2>/dev/null)

    # 2. Verifica se il driver in uso non è quello generico (vesa/efifb)
    # Cerchiamo driver come i915 (Intel), amdgpu/radeon (AMD), nouveau (Nvidia)
    CURRENT_DRIVER=$(basename $(readlink /sys/class/drm/card0/device/driver 2>/dev/null) 2>/dev/null)
    IS_GENERIC_DRIVER=false
    [[ "$CURRENT_DRIVER" == "vesa" || "$CURRENT_DRIVER" == "efifb" || -z "$CURRENT_DRIVER" ]] && IS_GENERIC_DRIVER=true

    USE_WAYLAND=false
    if [ -n "$HAS_RENDER_NODE" ] && [ "$IS_GENERIC_DRIVER" = false ] && [ -x /usr/bin/labwc ]; then
        USE_WAYLAND=true
    fi
fi

# Applichiamo la scelta
mkdir -p ~/.config/lxqt

if [ "$USE_WAYLAND" = true ]; then
    echo "Hardware moderno con driver '$CURRENT_DRIVER' rilevato. Avvio Wayland..."

    # Configura LXQt per Labwc
    echo "[General]
window_manager=labwc" > ~/.config/lxqt/session.conf

    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=LXQt

    # Se labwc fallisce per qualche motivo, lo script continuerà ed eseguirà X11 come fallback
    # Usiamo 'labwc -s startlxqt' (attenzione al typo nel tuo file precedente: startlxq -> startlxqt)
    labwc -s startlxqt && exit 0

    echo "Errore nell'avvio di Wayland, ripiego su X11..."
fi

# --- FALLBACK X11 ---
echo "Uso X11 (Openbox) come fallback o scelta predefinita."
echo "[General]
window_manager=openbox" > ~/.config/lxqt/session.conf

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=LXQt
exec startlxqt
