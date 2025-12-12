#!/usr/bin/env bash
# Change wallpaper using hyprpaper via direct socket communication
# Note: hyprctl hyprpaper commands have IPC issues in some versions,
# so we use direct socket communication instead

WALLPAPER="${1:-}"
MONITOR="${2:-}"  # Optional monitor name, defaults to all monitors

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

# Get Hyprland instance signature
USER_ID="$(id -u)"
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    HYPRLAND_INSTANCE_SIGNATURE="$(find "/run/user/$USER_ID/hypr/" -maxdepth 1 -mindepth 1 -type d -printf '%T@ %f\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2)"
fi
SOCKET_PATH="/run/user/$USER_ID/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.hyprpaper.sock"

# Check if socket exists
if [ ! -S "$SOCKET_PATH" ]; then
    echo "Error: hyprpaper socket not found at $SOCKET_PATH"
    echo "Is hyprpaper running?"
    exit 1
fi

# Function to send command to hyprpaper socket
send_to_hyprpaper() {
    echo "$1" | nc -UN "$SOCKET_PATH" 2>/dev/null || {
        # Fallback to socat if nc doesn't work
        echo "$1" | socat - UNIX-CONNECT:"$SOCKET_PATH" 2>/dev/null
    }
}

# Preload the new wallpaper
echo "Preloading wallpaper: $WALLPAPER"
send_to_hyprpaper "preload $WALLPAPER"

# Set wallpaper on specified monitor or all monitors
if [ -z "$MONITOR" ]; then
    echo "Setting wallpaper on all monitors"
    send_to_hyprpaper "wallpaper ,$WALLPAPER"
else
    echo "Setting wallpaper on monitor: $MONITOR"
    send_to_hyprpaper "wallpaper $MONITOR,$WALLPAPER"
fi

# Unload unused wallpapers to free memory
echo "Unloading unused wallpapers"
send_to_hyprpaper "unload unused"

echo "Wallpaper changed successfully!"
