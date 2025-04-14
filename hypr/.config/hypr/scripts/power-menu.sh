#!/bin/bash

choice=$(echo -e "Shutdown\nLogout\nLock" | wofi --width 200 --height 13s0 --dmenu --prompt "Power Menu")

case "$choice" in
    Shutdown)
        shutdown -h now
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Lock)
        hyprlock  # replace with your lock command if you use something else
        ;;
    *)
        ;;
esac
