#!/bin/bash

# CAPTURE="alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo"
CAPTURE=$(cat "$HOME/.config/waybar/sidetone_device.state")
PLAYBACK="alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"

# Check if pw-loopback is running
is_running() {
    pgrep -x pw-loopback >/dev/null
}

case "$1" in
    toggle)
        if is_running; then
            pkill -x pw-loopback
			sleep 0.2 # to allow wireplumber to unregister node
            echo "Sidetone stopped"
        else
            pw-loopback --capture "$CAPTURE" --playback "$PLAYBACK" &
            echo "Sidetone started"
        fi
        ;;
    status)
        if is_running; then
            echo "{\"text\": \"MIC: \", \"class\": \"active\"}"
        else
            echo "{\"text\": \"MIC: \", \"class\": \"inactive\"}"
        fi
        ;;
    *)
        echo "Usage: $0 {toggle|status}"
        ;;
esac
