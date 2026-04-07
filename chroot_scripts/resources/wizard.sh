#!/bin/bash
# This script creates a GUI wizard with yad, to be shown to the final user
# AFTER the pc has been prepared for donation.
# It's set to automatically run on the tmp '$MISO_USERNAME' profile and ask
# the user for the fields that are not defined in the skeleton.toml

set -x
export DISPLAY=:0

# 2. wizard grafico
YAD_CMD="yad --title=\"WEEE Open - System Setup\" --form --center --width=400 --window-icon=\"preferences-desktop-user\" --text=\"Configura il tuo account per iniziare.\""

PASS_WAS_SET=false
# Aggiungi i campi solo se le variabili non sono definite
if [ -z "$NEW_HOST" ]; then
    YAD_CMD="$YAD_CMD --field=\"Hostname\""
fi
if [ -z "$NEW_USER" ]; then
    YAD_CMD="$YAD_CMD --field=\"Username\""
fi
if [ -z "$NEW_PASS" ]; then
    YAD_CMD="$YAD_CMD --field=\"Password:H\" --field=\"Repeat Password:H\""
    PASS_WAS_SET=true
fi
if [ -z "$NEW_LOCALE" ]; then
    TAD_CMD="$YAD_CMD --field=\"Language\"" # TODO make this into a dropdown menu
fi

YAD_CMD="$YAD_CMD --button=\"Done:0\" --button=\"Exit:1\""

# Esegui yad solo se ci sono campi da mostrare
if [[ "$YAD_CMD" == *"--field="* ]]; then
    DATA=$(eval $YAD_CMD)
    [[ $? -ne 0 ]] && exit 1

    FIELD_INDEX=1
    if [ -z "$NEW_HOST" ]; then
        NEW_HOST=$(echo $DATA | cut -d'|' -f$FIELD_INDEX)
        FIELD_INDEX=$((FIELD_INDEX+1))
    fi
    if [ -z "$NEW_USER" ]; then
        NEW_USER=$(echo $DATA | cut -d'|' -f$FIELD_INDEX)
        FIELD_INDEX=$((FIELD_INDEX+1))
    fi
    if $PASS_WAS_SET; then
        NEW_PASS=$(echo $DATA | cut -d'|' -f$FIELD_INDEX)
        CONFIRM=$(echo $DATA | cut -d'|' -f$((FIELD_INDEX+1)))
    fi
fi

# 3. validazione
if ($PASS_WAS_SET && [[ "$NEW_PASS" != "$CONFIRM" ]]) || [[ -z "$NEW_USER" ]] || [[ -z "$NEW_HOST" ]]; then
    yad --error --text="Data invalid or password not matching."
    exec $0
fi

export NEW_HOST
export NEW_USER
export NEW_PASS

/tmp/finish_install.sh
