#!/bin/bash

direction=$1  # should be "up" or "down"

current=$(hyprctl activeworkspace -j | jq '.id')

if [[ "$direction" == "down" ]]; then
    if [ "$current" -lt 3 ]; then
        next=$((current + 1))
    else
        next=1
    fi
elif [[ "$direction" == "up" ]]; then
    if [ "$current" -gt 1 ]; then
        next=$((current - 1))
    else
        next=3
    fi
else
    echo "Usage: $0 [up|down]"
    exit 1
fi

hyprctl dispatch workspace "$next"