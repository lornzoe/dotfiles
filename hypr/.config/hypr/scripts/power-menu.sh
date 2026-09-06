#!/bin/bash

choice=$(echo -e "Shutdown\nReboot\nLogout\nLock" | wofi --width 200 --height 130 --dmenu --prompt "Power Menu")

case "$choice" in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Lock)
        # hyprlock is not installed yet (extra/hyprlock)
        command -v hyprlock >/dev/null 2>&1 && hyprlock || notify-send "Lock" "hyprlock is not installed"
        ;;
    *)
        ;;
esac
