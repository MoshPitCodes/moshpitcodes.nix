#!/usr/bin/env bash

dir="$HOME/Pictures/Screenshots"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# Fix flameshot multi-monitor positioning on Hyprland
# Hyprland windowrule 'move' is monitor-relative, so we use
# movewindowpixel to set absolute 0,0 after flameshot opens
fix_position() {
	for i in $(seq 1 20); do
		if hyprctl clients -j | grep -q '"title": "flameshot"'; then
			hyprctl dispatch movewindowpixel "exact 0 0, title:flameshot"
			break
		fi
		sleep 0.05
	done
}

copy() {
	fix_position &
	flameshot gui --clipboard
}

save() {
	fix_position &
	flameshot gui --path "$dir"
}

gui() {
	fix_position &
	flameshot gui
}

full() {
	flameshot full --clipboard
}

if [[ "$1" == "--copy" ]]; then
	copy
elif [[ "$1" == "--save" ]]; then
	save
elif [[ "$1" == "--full" ]]; then
	full
elif [[ "$1" == "--gui" ]]; then
	gui
else
	gui
fi

exit 0
