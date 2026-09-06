#!/bin/bash

# NOTE: arch-menu.sh's `system` submenu now covers the same actions via walker
# (`arch-menu.sh system`). This script is kept as the direct SUPER+ESCAPE path;
# collapse the two if you'd rather maintain one menu.
choice=$(echo -e "Shutdown\nReboot\nLogout\nLock" | walker --dmenu -p "Power Menu")

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
