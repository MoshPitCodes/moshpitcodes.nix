#!/usr/bin/env bash

dir="$HOME/Pictures/Screenshots"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

copy() {
	grimblast --notify copy area
}

save() {
	grimblast --notify save area "$file"
}

gui() {
	grimblast --notify copy area
}

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "--copy" ]]; then
	copy
elif [[ "$1" == "--save" ]]; then
	save
elif [[ "$1" == "--gui" ]]; then
	gui
else
	gui
fi

exit 0
