#!/bin/bash

# --- CONFIGURATION ---
# Change these to match your preferred apps
TERMINAL="kitty"
EDITOR="nvim"
BROWSER="zen-browser"
FILE_MANAGER="dolphin"

# Set to true when going directly to a submenu, so we can exit directly
BACK_TO_EXIT=false

back_to() {
  local parent_menu="$1"
  if [[ "$BACK_TO_EXIT" == "true" ]]; then
    exit 0
  elif [[ -n "$parent_menu" ]]; then
    "$parent_menu"
  else
    show_main_menu
  fi
}

# Wrapper for Walker in dmenu mode
menu() {
  local prompt="$1"
  local options="$2"
  local extra="$3"
  
  # Note: Removed Omarchy specific styling flags to ensure compatibility
  echo -e "$options" | walker --dmenu -p "$prompt" $extra 2>/dev/null
}

# Launch a command in the terminal
terminal() {
  $TERMINAL -e sh -c "$@"
}

# Launch a command in terminal and keep it open (useful for updates/installs)
present_terminal() {
  # Logic adapts to Kitty. If using Alacritty/Foot, command flags may differ.
  $TERMINAL --hold -e sh -c "$@"
}

open_in_editor() {
  notify-send "Editing config file" "$1"
  $TERMINAL -e $EDITOR "$1"
}

# --- MENUS ---

show_main_menu() {
  # Simplified main menu for standard Arch usage
  local choice
  choice=$(menu "Go" "  Capture\n󰀻  Apps\n  Setup\n  Keybindings\n  System")
  
  case "${choice,,}" in
    *capture*) show_capture_menu ;;
    *apps*) walker ;; # Launch standard Walker app drawer
    *setup*) show_setup_menu ;;
    *keybindings*) open_in_editor "$HOME/.config/hypr/hyprland.conf" ;; # Adjust path if needed
    *system*) show_system_menu ;;
  esac
}

show_capture_menu() {
  case $(menu "Capture" "  Screenshot (Region)\n  Screenshot (Full)\n  Screenrecord (Stop)\n  Screenrecord (Start)\n󰃉  Color Picker") in
    *Region*) grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot taken (Region)" ;;
    *Full*) grim - | wl-copy && notify-send "Screenshot taken (Full)" ;;
    *Stop*) pkill wf-recorder && notify-send "Recording Stopped" ;;
    *Start*) wf-recorder -f "$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4" & notify-send "Recording Started" ;;
    *Color*) hyprpicker -a ;;
    *) show_main_menu ;;
  esac
}

show_setup_menu() {
  # Replaces Omarchy custom tools with standard GUI/TUI tools
  case $(menu "Setup" "  Audio Control\n  Wi-Fi Menu\n󰂯  Bluetooth\n󰍹  Monitors\n  Edit Hyprland Config\n  Edit Walker Config\n󰔎  Toggle Waybar") in
    *Audio*) pavucontrol ;;
    *Wi-Fi*) nm-connection-editor ;; # Or use 'nmtui' if you prefer terminal
    *Bluetooth*) blueman-manager ;;
    *Monitors*) wdisplays ;; # Requires wdisplays or nwg-displays
    *Hyprland*) open_in_editor "$HOME/.config/hypr/hyprland.conf" ;;
    *Walker*) open_in_editor "$HOME/.config/walker/config.toml" ;;
    *Waybar*) pkill -SIGUSR1 waybar ;; # Toggles Waybar visibility
    *) show_main_menu ;;
  esac
}

show_system_menu() {
  # Uses standard systemd commands
  case $(menu "System" "  Lock\n󰤄  Suspend\n󰜉  Reboot\n󰐥  Shutdown\n󰍃  Logout") in
    *Lock*) hyprlock ;; # Ensure hyprlock is installed, or change to swaylock
    *Suspend*) systemctl suspend ;;
    *Reboot*) systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
    *Logout*) hyprctl dispatch exit ;;
    *) back_to show_main_menu ;;
  esac
}

# --- ENTRY POINT ---

if [[ -n "$1" ]]; then
  BACK_TO_EXIT=true
  # Map arguments to menus
  case "${1,,}" in
    system) show_system_menu ;;
    setup) show_setup_menu ;;
    capture) show_capture_menu ;;
    *) show_main_menu ;;
  esac
else
  show_main_menu
fi