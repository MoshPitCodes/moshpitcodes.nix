#!/usr/bin/env bash
# Shared library for NixOS installation scripts
# Source this file in other scripts: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Color definitions (with fallback if tput not available)
if [[ -t 1 ]] && command -v tput &> /dev/null; then
    NORMAL=$(tput sgr0 2>/dev/null || echo "")
    RED=$(tput setaf 1 2>/dev/null || echo "")
    GREEN=$(tput setaf 2 2>/dev/null || echo "")
    YELLOW=$(tput setaf 3 2>/dev/null || echo "")
    CYAN=$(tput setaf 6 2>/dev/null || echo "")
    BRIGHT=$(tput bold 2>/dev/null || echo "")
else
    NORMAL=""
    RED=""
    GREEN=""
    YELLOW=""
    CYAN=""
    BRIGHT=""
fi

# Error handling
error() {
    echo -e "${RED}ERROR:${NORMAL} $1" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}WARNING:${NORMAL} $1" >&2
}

info() {
    echo -e "${GREEN}INFO:${NORMAL} $1"
}

# Confirmation prompt
confirm() {
    local prompt="${1:-Continue?}"
    echo -en "${prompt} [${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Check if command exists
require_command() {
    local cmd="$1"
    local install_hint="${2:-Install $cmd and try again}"

    if ! command -v "$cmd" &> /dev/null; then
        error "Required command '$cmd' not found. $install_hint"
    fi
}

# Validate directory exists
require_directory() {
    local dir="$1"
    local message="${2:-Directory not found: $dir}"

    if [[ ! -d "$dir" ]]; then
        error "$message"
    fi
}

# Validate file exists
require_file() {
    local file="$1"
    local message="${2:-File not found: $file}"

    if [[ ! -f "$file" ]]; then
        error "$message"
    fi
}

# Get repository root directory
get_repo_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

# Check if running with sudo
is_sudo() {
    [[ $EUID -eq 0 ]]
}

# Ensure NOT running as root
require_not_root() {
    if is_sudo; then
        error "This script should NOT be run as root"
    fi
}

# Ensure sudo is available
require_sudo_available() {
    if ! sudo -v &> /dev/null; then
        error "sudo is required but not available or password incorrect"
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "${ID:-unknown}"
    elif [[ -f /etc/nixos/configuration.nix ]] || command -v nixos-version &> /dev/null; then
        echo "nixos"
    else
        echo "unknown"
    fi
}

# Get package manager for current distribution
get_package_manager() {
    local distro=$(detect_distro)

    case "$distro" in
        nixos)
            echo "nix-env -iA nixos"
            ;;
        ubuntu|debian|pop|mint|kali)
            echo "apt"
            ;;
        fedora|rhel|centos|rocky|alma)
            echo "dnf"
            ;;
        arch|manjaro|endeavouros)
            echo "pacman -S"
            ;;
        opensuse*|sles)
            echo "zypper install"
            ;;
        alpine)
            echo "apk add"
            ;;
        void)
            echo "xbps-install"
            ;;
        gentoo)
            echo "emerge"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Suggest package installation based on distribution
suggest_install() {
    local package="$1"
    local distro=$(detect_distro)
    local pkg_manager=$(get_package_manager)

    error "Required command '$package' not found. Install it with:
  ${YELLOW}Distribution detected:${NORMAL} $distro

  ${GREEN}Installation command:${NORMAL}
    $(get_install_command "$package")"
}

# Get specific installation command for a package
get_install_command() {
    local package="$1"
    local distro=$(detect_distro)

    case "$distro" in
        nixos)
            echo "nix-shell -p $package"
            ;;
        ubuntu|debian|pop|mint|kali)
            echo "sudo apt update && sudo apt install -y $package"
            ;;
        fedora|rhel|centos|rocky|alma)
            echo "sudo dnf install -y $package"
            ;;
        arch|manjaro|endeavouros)
            echo "sudo pacman -S --noconfirm $package"
            ;;
        opensuse*|sles)
            echo "sudo zypper install -y $package"
            ;;
        alpine)
            echo "sudo apk add $package"
            ;;
        void)
            echo "sudo xbps-install -y $package"
            ;;
        gentoo)
            echo "sudo emerge $package"
            ;;
        *)
            echo "# Unknown distribution - install $package manually"
            ;;
    esac
}

# Check if NixOS is available
is_nixos() {
    [[ -f /etc/nixos/configuration.nix ]] || command -v nixos-version &> /dev/null
}

# Require NixOS environment
require_nixos() {
    if ! is_nixos; then
        error "This script requires NixOS.
If you want to install NixOS with this configuration:
  1. Install NixOS: https://nixos.org/download.html
  2. Or install Nix package manager: curl -L https://nixos.org/nix/install | sh
  3. Then run this script again"
    fi
}
