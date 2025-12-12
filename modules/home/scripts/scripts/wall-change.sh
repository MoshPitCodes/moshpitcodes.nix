#!/usr/bin/env bash
# Change wallpaper using swww with transition effects
# Usage: wall-change <path-to-wallpaper> [monitor]

WALLPAPER="${1:-}"
MONITOR="${2:-}"

if [ -z "$WALLPAPER" ]; then
    echo "Usage: wall-change <path-to-wallpaper> [monitor]"
    echo "  If monitor is not specified, wallpaper will be set on all monitors"
    exit 1
fi

# Check if file exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper file not found: $WALLPAPER"
    exit 1
fi

# Check if swww-daemon is running, start if not
if ! pgrep -x "swww-daemon" > /dev/null; then
    echo "Starting swww-daemon..."
    swww-daemon &
    sleep 1
fi

# Set wallpaper with transition effects
if [ -z "$MONITOR" ]; then
    echo "Setting wallpaper on all monitors: $WALLPAPER"
    swww img "$WALLPAPER" \
        --transition-type wipe \
        --transition-duration 2 \
        --transition-fps 60 \
        --transition-angle 30 \
        --transition-step 90
else
    echo "Setting wallpaper on monitor $MONITOR: $WALLPAPER"
    swww img --outputs "$MONITOR" "$WALLPAPER" \
        --transition-type wipe \
        --transition-duration 2 \
        --transition-fps 60 \
        --transition-angle 30 \
        --transition-step 90
fi

echo "Wallpaper changed successfully!"
