#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

init() {
    # Colors
    NORMAL=$(tput sgr0)
    WHITE=$(tput setaf 7)
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    BRIGHT=$(tput bold)
    UNDERLINE=$(tput smul)
}

error() {
    echo -e "${RED}ERROR:${NORMAL} $1" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}WARNING:${NORMAL} $1"
}

info() {
    echo -e "${GREEN}INFO:${NORMAL} $1"
}

confirm() {
    echo -en "[${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
}

print_header() {
    echo -E "$CYAN
     _   _ _       ___        ___           _        _ _
    | \ | (_)_  __/ _ \ ___  |_ _|_ __  ___| |_ __ _| | | ___ _ __
    |  \| | \ \/ / | | / __|  | || '_ \/ __| __/ _' | | |/ _ \ '__|
    | |\  | |>  <| |_| \__ \  | || | | \__ \ || (_| | | |  __/ |
    |_| \_|_/_/\_\\\\___/|___/ |___|_| |_|___/\__\__,_|_|_|\___|_|


                      ! DO NOT run as root ! $GREEN
                        -> '"./install.sh"' $NORMAL

    "
}

validate_prerequisites() {
    info "Checking prerequisites..."

    # Check if running from repository root
    if [[ ! -f "flake.nix" ]]; then
        error "flake.nix not found. Please run this script from the repository root."
    fi

    # Check if required directories exist
    if [[ ! -d "hosts" ]]; then
        error "hosts/ directory not found. Repository structure may be incomplete."
    fi

    if [[ ! -d "wallpapers" ]]; then
        warning "wallpapers/ directory not found. Wallpaper copying will be skipped."
    fi

    # Check if secrets.nix exists
    if [[ ! -f "secrets.nix" ]]; then
        error "secrets.nix not found. Please create it from secrets.nix.template"
    fi

    info "Prerequisites check passed."
}

get_username() {
    # Try to read existing username from secrets.nix
    if [[ -f "secrets.nix" ]]; then
        CURRENT_USERNAME=$(grep -oP '^\s*username\s*=\s*"\K[^"]+' secrets.nix 2>/dev/null || echo "")
        if [[ -n "$CURRENT_USERNAME" ]]; then
            info "Found existing username in secrets.nix: ${YELLOW}${CURRENT_USERNAME}${NORMAL}"
            echo -en "Keep this username? "
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                username="$CURRENT_USERNAME"
                return
            fi
        fi
    fi

    # Prompt for new username
    echo -en "Enter your ${GREEN}username${NORMAL}: ${YELLOW}"
    read username
    echo -en "$NORMAL"
    echo -en "Use ${YELLOW}\"$username\"${NORMAL} as ${GREEN}username${NORMAL}? "
    confirm
}

set_username() {
    info "Updating username in secrets.nix..."

    # Create backup of secrets.nix
    cp secrets.nix secrets.nix.backup

    # Update username in secrets.nix
    if grep -q '^\s*username\s*=' secrets.nix; then
        sed -i "s/^\(\s*username\s*=\s*\)\"[^\"]*\"/\1\"${username}\"/" secrets.nix
        info "Username updated to: ${YELLOW}${username}${NORMAL}"
    else
        error "Could not find username field in secrets.nix"
    fi
}

get_host() {
    echo -e "\nChoose a ${GREEN}host${NORMAL}:"
    echo -e "  [${YELLOW}D${NORMAL}]esktop"
    echo -e "  [${YELLOW}L${NORMAL}]aptop"
    echo -e "  [${YELLOW}V${NORMAL}]irtual Machine"
    echo -e "  [${YELLOW}W${NORMAL}]SL (Windows Subsystem for Linux)"
    echo -e "  [${YELLOW}M${NORMAL}]Ware (VMware Guest)"
    echo -en "\nYour choice: "
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[Dd]$ ]]; then
        HOST='desktop'
    elif [[ $REPLY =~ ^[Ll]$ ]]; then
        HOST='laptop'
    elif [[ $REPLY =~ ^[Vv]$ ]]; then
        HOST='vm'
    elif [[ $REPLY =~ ^[Ww]$ ]]; then
        HOST='wsl'
    elif [[ $REPLY =~ ^[Mm]$ ]]; then
        HOST='vmware-guest'
    else
        error "Invalid choice. Please select D/L/V/W/M."
    fi

    # Verify host configuration exists
    if [[ ! -d "hosts/${HOST}" ]]; then
        error "Host configuration not found: hosts/${HOST}"
    fi

    echo -en "$NORMAL"
    echo -en "Use the ${YELLOW}\"$HOST\"${NORMAL} ${GREEN}host${NORMAL}? "
    confirm
}

aseprite() {
    info "Aseprite configuration is managed in modules/home/aseprite/aseprite.nix"
    info "To disable Aseprite, comment out the import in modules/home/default.nix after installation"
    echo -en "\nContinue with installation? "
    confirm
}

install() {
    echo -e "\n${CYAN}${BRIGHT}START INSTALL PHASE${NORMAL}\n"

    # Create basic directories
    info "Creating user directories..."
    mkdir -p ~/Music || warning "Failed to create ~/Music"
    mkdir -p ~/Documents || warning "Failed to create ~/Documents"
    mkdir -p ~/Pictures/wallpapers/randomwallpaper || warning "Failed to create ~/Pictures/wallpapers"
    mkdir -p ~/Documents/${username} || warning "Failed to create ~/Documents/${username}"
    info "Directories created successfully"

    # Copy the wallpapers if they exist
    if [[ -d "wallpapers" ]] && [[ -n "$(ls -A wallpapers 2>/dev/null)" ]]; then
        info "Copying wallpapers..."
        cp -r wallpapers/* ~/Pictures/wallpapers/ || warning "Some wallpapers failed to copy"
        info "Wallpapers copied successfully"
    else
        warning "No wallpapers found to copy, skipping..."
    fi

    # Handle hardware configuration based on host type
    if [[ "$HOST" == "wsl" ]]; then
        info "WSL detected - skipping hardware-configuration.nix (not needed for WSL)"
    elif [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
        info "Copying hardware-configuration.nix to hosts/${HOST}/"
        cp /etc/nixos/hardware-configuration.nix hosts/${HOST}/hardware-configuration.nix || \
            error "Failed to copy hardware-configuration.nix"
        info "Hardware configuration copied successfully"
    else
        warning "No /etc/nixos/hardware-configuration.nix found"
        warning "For fresh installs, you may need to generate it first with:"
        warning "  sudo nixos-generate-config --show-hardware-config > hosts/${HOST}/hardware-configuration.nix"
        echo -en "\nContinue anyway? "
        confirm
    fi

    # Last Confirmation
    echo -e "\n${YELLOW}${BRIGHT}READY TO BUILD SYSTEM${NORMAL}"
    echo -e "Host: ${GREEN}${HOST}${NORMAL}"
    echo -e "Username: ${GREEN}${username}${NORMAL}"
    echo -en "\nStart the system build? "
    confirm

    # Build the system (flakes + home manager)
    info "Building the system with nixos-rebuild..."
    echo -e "${CYAN}This may take a while on first build...${NORMAL}\n"

    if sudo nixos-rebuild switch --flake .#${HOST}; then
        echo -e "\n${GREEN}${BRIGHT}✓ Installation completed successfully!${NORMAL}\n"
        info "You may need to reboot for all changes to take effect"
    else
        error "nixos-rebuild failed. Check the output above for errors."
    fi
}

main() {
    init

    print_header

    # Validate environment before proceeding
    validate_prerequisites

    get_username
    set_username
    get_host

    aseprite
    install
}

# Run main and ensure clean exit
main
exit 0
