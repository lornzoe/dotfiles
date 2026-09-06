#!/usr/bin/env bash
# Waybar custom clock, lowercased.
# Replaces lowercase-clock.js -- that needed nodejs (not installed) and span
# a setInterval loop inside waybar's exec. Waybar's own `interval` handles
# the refresh, so this just prints one JSON object and exits.

text=$(date '+%a %b %-d %-I:%M %p' | tr '[:upper:]' '[:lower:]')
tooltip=$(date '+%A, %B %-d %Y  %H:%M:%S')

printf '{"text":"%s","tooltip":"%s","class":"clock-module"}\n' "$text" "$tooltip"
