#!/bin/bash

STATE_FILE="$HOME/.config/waybar/sidetone_device.state"

# Device names
DEVICE1="alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo"
DEVICE2="alsa_input.usb-Generic_USB_Audio-00.HiFi__Mic1__source"

# Path to your sidetone script
SIDETONE_SCRIPT="$HOME/.config/waybar/scripts/sidetone.sh"

# Initialize state file if missing
if [ ! -f "$STATE_FILE" ]; then
    echo "$DEVICE1" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

restart_sidetone() {
    # Stop sidetone if running
    if pgrep -x pw-loopback >/dev/null; then
        pkill -x pw-loopback
        # Wait briefly to avoid race condition
        sleep 0.3
        # Restart with new capture device
        "$SIDETONE_SCRIPT" toggle >/dev/null
    fi
}

case "$1" in
    toggle)
        if [ "$CURRENT" = "$DEVICE1" ]; then
            echo "$DEVICE2" > "$STATE_FILE"
        else
            echo "$DEVICE1" > "$STATE_FILE"
        fi
        restart_sidetone
        ;;
    status)
        if [ "$CURRENT" = "$DEVICE1" ]; then
            echo "{\"text\": \"BLUE MIC\", \"class\": \"active\"}"
        else
            echo "{\"text\": \"HP MIC\", \"class\": \"active\"}"
        fi
        ;;
    *)
        echo "Usage: $0 {toggle|status}"
        ;;
esac
