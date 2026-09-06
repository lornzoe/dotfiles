#!/bin/bash

STATE_FILE="$HOME/.config/waybar/sidetone_device.state"

# Device names -- these are PipeWire node.name values, verify with:
#   pw-cli ls Node | grep node.name
#
# Both of the previous values were stale on this machine:
#   - the C-Media "USB Advanced Audio Device" is not connected at all
#   - "...HiFi__Mic1__source" does not exist; the real node is "...HiFi__Mic__source"
# DEVICE1 is remapped to the mutalk dongle, which is the current default source.
DEVICE1="alsa_input.usb-Shiftall_Inc._mutalk_2_Dongle_D2U10209527-B-00.mono-fallback"
DEVICE2="alsa_input.usb-Generic_USB_Audio-00.HiFi__Mic__source"

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
            echo "{\"text\": \"MUTALK\", \"class\": \"active\"}"
        else
            echo "{\"text\": \"HP MIC\", \"class\": \"active\"}"
        fi
        ;;
    *)
        echo "Usage: $0 {toggle|status}"
        ;;
esac
