#!/usr/bin/env bash
# Interactive installer for NixOS configuration

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Configuration
REPO_ROOT="$(get_repo_root)"
cd "$REPO_ROOT"

# Validate prerequisites
validate_prerequisites() {
    info "Checking prerequisites..."

    require_not_root
    require_file "flake.nix" "flake.nix not found. Run this from repository root."
    require_directory "hosts" "hosts/ directory not found. Repository incomplete."
    require_file "secrets.nix" "secrets.nix not found. Create it from secrets.nix.example"

    if [[ ! -d "wallpapers" ]]; then
        warning "wallpapers/ directory not found. Wallpaper copying will be skipped."
    fi

    info "Prerequisites check passed."
}

# Get or confirm username
get_username() {
    local username=""

    # Try reading existing username
    if [[ -f "secrets.nix" ]]; then
        username=$(grep -oP '^\s*username\s*=\s*"\K[^"]+' secrets.nix 2>/dev/null || echo "")

        if [[ -n "$username" ]]; then
            info "Found username in secrets.nix: ${YELLOW}${username}${NORMAL}"
            if confirm "Keep this username?"; then
                echo "$username"
                return
            fi
        fi
    fi

    # Prompt for new username
    while [[ -z "$username" ]]; do
        echo -en "Enter your ${GREEN}username${NORMAL}: "
        read username
        [[ -n "$username" ]] && confirm "Use '${YELLOW}${username}${NORMAL}' as username?" || username=""
    done

    echo "$username"
}

# Update username in secrets.nix
set_username() {
    local username="$1"
    info "Updating username in secrets.nix..."

    cp secrets.nix secrets.nix.backup
    trap 'rm -f secrets.nix.backup' EXIT

    if sed -i "s/^\(\s*username\s*=\s*\)\"[^\"]*\"/\1\"${username}\"/" secrets.nix; then
        info "Username updated to: ${YELLOW}${username}${NORMAL}"
    else
        mv secrets.nix.backup secrets.nix
        error "Failed to update username in secrets.nix"
    fi
}

# Select host configuration
get_host() {
    echo -e "\n${GREEN}Choose a host:${NORMAL}"
    echo "  [D]esktop"
    echo "  [L]aptop"
    echo "  [V]M (Virtual Machine)"
    echo "  [W]SL (Windows Subsystem for Linux)"
    echo "  [M]Ware (VMware Guest)"
    echo -en "\nYour choice: "

    local host=""
    read -n 1 -r choice
    echo

    case "${choice,,}" in
        d) host="desktop" ;;
        l) host="laptop" ;;
        v) host="vm" ;;
        w) host="wsl" ;;
        m) host="vmware-guest" ;;
        *) error "Invalid choice. Select D/L/V/W/M." ;;
    esac

    require_directory "hosts/$host" "Host configuration not found: hosts/$host"
    confirm "Use the '${YELLOW}${host}${NORMAL}' host?" || exit 0

    echo "$host"
}

# Install system
install_system() {
    local host="$1"
    local username="$2"

    echo -e "\n${CYAN}${BRIGHT}INSTALLATION${NORMAL}\n"

    # Create user directories
    info "Creating user directories..."
    mkdir -p ~/Music ~/Documents ~/Pictures/wallpapers/randomwallpaper ~/Documents/"$username" || \
        warning "Some directories failed to create"

    # Copy wallpapers
    if [[ -d "wallpapers" ]] && [[ -n "$(ls -A wallpapers 2>/dev/null)" ]]; then
        info "Copying wallpapers..."
        cp -r wallpapers/* ~/Pictures/wallpapers/ || warning "Some wallpapers failed to copy"
    else
        warning "No wallpapers to copy, skipping..."
    fi

    # Handle hardware configuration
    if [[ "$host" == "wsl" ]]; then
        info "WSL detected - skipping hardware-configuration.nix"
    elif [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
        info "Copying hardware-configuration.nix to hosts/$host/"
        cp /etc/nixos/hardware-configuration.nix "hosts/$host/hardware-configuration.nix"
    else
        warning "No /etc/nixos/hardware-configuration.nix found"
        warning "Generate it with: sudo nixos-generate-config --show-hardware-config > hosts/$host/hardware-configuration.nix"
        confirm "Continue anyway?" || exit 0
    fi

    # Final confirmation
    echo -e "\n${YELLOW}${BRIGHT}READY TO BUILD${NORMAL}"
    echo "  Host:     ${GREEN}$host${NORMAL}"
    echo "  Username: ${GREEN}$username${NORMAL}"
    confirm "\nStart system build?" || exit 0

    # Build system
    info "Building system (this may take a while)..."
    if sudo nixos-rebuild switch --flake ".#$host"; then
        echo -e "\n${GREEN}${BRIGHT}✓ Installation complete!${NORMAL}\n"
        info "Reboot recommended for all changes to take effect"
    else
        error "nixos-rebuild failed. Check output above for errors."
    fi
}

# Main installation flow
main() {
    echo -e "${CYAN}${BRIGHT}"
    echo "╔══════════════════════════════════════╗"
    echo "║     NixOS Configuration Installer    ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NORMAL}"

    validate_prerequisites

    local username=$(get_username)
    set_username "$username"

    local host=$(get_host)

    install_system "$host" "$username"
}

main
