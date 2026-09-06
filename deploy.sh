#!/usr/bin/env bash
# Stow-compatible deploy without needing GNU stow installed.
# Symlinks ~/dotfiles/<pkg>/.config/<pkg> -> ~/.config/<pkg>, exactly as
# `stow <pkg>` would. Safe to re-run. Replaced by `chezmoi apply` later.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

PKGS=("$@")
[ ${#PKGS[@]} -eq 0 ] && PKGS=(hypr waybar wofi kitty btop walker elephant)

for pkg in "${PKGS[@]}"; do
    src="$REPO/$pkg/.config/$pkg"
    dst="$HOME/.config/$pkg"
    [ -d "$src" ] || { echo "skip   $pkg (no $src)"; continue; }

    if [ -L "$dst" ]; then
        [ "$(readlink -f "$dst")" = "$src" ] && { echo "ok     $pkg (already linked)"; continue; }
        rm "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$BACKUP"; mv "$dst" "$BACKUP/$pkg"
        echo "backup $pkg -> $BACKUP/$pkg"
    fi

    ln -s "$src" "$dst"
    echo "link   ~/.config/$pkg -> $src"
done
