#!/usr/bin/env bash

set -euo pipefail

config_file="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"

if [[ ! -f "$config_file" ]]; then
	exit 1
fi

keybinds=$(
	awk '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*bind[a-z]*[[:space:]]*=/ {
      line = $0
      sub(/^[[:space:]]*bind[a-z]*[[:space:]]*=[[:space:]]*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
    }
  ' "$config_file"
)

keybinds=$(printf "%s\n" "$keybinds" | sed 's/,\([^,]*\)$/ = \1/' | sed 's/, exec//g' | sed 's/^,//g')
rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' <<<"$keybinds"
