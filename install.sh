#!/usr/bin/env bash

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
    |_| \_|_/_/\_\\\___/|___/ |___|_| |_|___/\__\__,_|_|_|\___|_|


                      ! DO NOT run as root ! $GREEN
                        -> './install.sh' $NORMAL

    "
}

get_secrets_method() {
    echo -e "\n${GREEN}Choose secrets management method:${NORMAL}"
    echo -e "  [${YELLOW}1${NORMAL}] Use ${GREEN}secrets.nix${NORMAL} file (recommended for new users)"
    echo -e "  [${YELLOW}2${NORMAL}] Use ${GREEN}environment variables${NORMAL} (advanced users)"
    echo -en "Enter your choice [${YELLOW}1${NORMAL}-2]: "
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[1]$ ]]; then
        SECRETS_METHOD="file"
    elif [[ $REPLY =~ ^[2]$ ]]; then
        SECRETS_METHOD="env"
    else
        echo "Invalid choice. Defaulting to secrets.nix file method."
        SECRETS_METHOD="file"
    fi
}

get_user_info() {
    echo -en "\nEnter your ${GREEN}username${NORMAL}: $YELLOW"
    read username
    echo -en "$NORMAL"
    echo -en "Use ${YELLOW}\"$username\"${NORMAL} as ${GREEN}username${NORMAL}? "
    confirm

    echo -en "Enter your ${GREEN}Git username${NORMAL}: $YELLOW"
    read git_username
    echo -en "$NORMAL"
    echo -en "Use ${YELLOW}\"$git_username\"${NORMAL} as ${GREEN}Git username${NORMAL}? "
    confirm

    echo -en "Enter your ${GREEN}Git email${NORMAL}: $YELLOW"
    read git_email
    echo -en "$NORMAL"
    echo -en "Use ${YELLOW}\"$git_email\"${NORMAL} as ${GREEN}Git email${NORMAL}? "
    confirm
}

get_wifi_info() {
    echo -en "\nConfigure WiFi credentials? [${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -en "Enter WiFi ${GREEN}SSID${NORMAL}: $YELLOW"
        read wifi_ssid
        echo -en "$NORMAL"

        echo -en "Enter WiFi ${GREEN}password${NORMAL}: $YELLOW"
        read -s wifi_password
        echo -en "$NORMAL"
        echo # newline after hidden input

        CONFIGURE_WIFI=true
    else
        CONFIGURE_WIFI=false
    fi
}

setup_secrets_file() {
    echo -e "\n${GREEN}Setting up secrets.nix file...${NORMAL}"

    # Copy template if secrets.nix doesn't exist or is empty
    if [[ ! -f ./secrets.nix ]] || [[ ! -s ./secrets.nix ]]; then
        echo -e "Copying secrets.nix.example to secrets.nix"
        cp ./secrets.nix.example ./secrets.nix
    fi

    # Update username
    sed -i "s/username = \".*\";/username = \"${username}\";/" ./secrets.nix

    # Update git configuration
    sed -i "s/userName = \".*\";/userName = \"${git_username}\";/" ./secrets.nix
    sed -i "s/userEmail = \".*\";/userEmail = \"${git_email}\";/" ./secrets.nix

    # Update WiFi configuration if provided
    if [[ $CONFIGURE_WIFI == true ]]; then
        sed -i "s/wifiSSID = \".*\";/wifiSSID = \"${wifi_ssid}\";/" ./secrets.nix
        sed -i "s/wifiPassword = \".*\";/wifiPassword = \"${wifi_password}\";/" ./secrets.nix
    fi

    echo -e "${GREEN}✓${NORMAL} secrets.nix configured successfully"
}

setup_environment_variables() {
    echo -e "\n${GREEN}Setting up environment variables...${NORMAL}"

    # Create .env file
    cat > .env << EOF
# NixOS Configuration Environment Variables
NIXOS_USERNAME=${username}
GIT_USERNAME=${git_username}
GIT_EMAIL=${git_email}
NIXOS_REPO_NAME=moshpitcodes.nix
EOF

    if [[ $CONFIGURE_WIFI == true ]]; then
        cat >> .env << EOF
WIFI_SSID=${wifi_ssid}
WIFI_PASSWORD=${wifi_password}
EOF
    fi

    echo -e "${GREEN}✓${NORMAL} .env file created"
    echo -e "${YELLOW}Important:${NORMAL} Run ${GREEN}source .env${NORMAL} before building the system"
}

configure_secrets() {
    if [[ $SECRETS_METHOD == "file" ]]; then
        setup_secrets_file
    else
        setup_environment_variables
    fi
}

get_host() {
    echo -en "\nChoose a ${GREEN}host${NORMAL} - [${YELLOW}D${NORMAL}]esktop, [${YELLOW}L${NORMAL}]aptop or [${YELLOW}V${NORMAL}]irtual machine: "
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[Dd]$ ]]; then
        HOST='desktop'
    elif [[ $REPLY =~ ^[Ll]$ ]]; then
        HOST='laptop'
    elif [[ $REPLY =~ ^[Vv]$ ]]; then
        HOST='vm'
    else
        echo "Invalid choice. Please select 'D' for desktop, 'L' for laptop or 'V' for virtual machine."
        exit 1
    fi

    echo -en "$NORMAL"
    echo -en "Use the$YELLOW \"$HOST\"$NORMAL ${GREEN}host${NORMAL} ? "
    confirm
}

aseprite() {
    # whether to install aseprite or not
    echo -en "\nDisable ${GREEN}Aseprite${NORMAL} (faster install) ? [${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    sed -i '3s/  /  # /' modules/home/aseprite/aseprite.nix
}

install() {
    echo -e "\n${RED}START INSTALL PHASE${NORMAL}\n"

    # Create basic directories
    echo -e "Creating folders:"
    echo -e "    - ${MAGENTA}~/Music${NORMAL}"
    echo -e "    - ${MAGENTA}~/Documents${NORMAL}"
    echo -e "    - ${MAGENTA}~/Pictures/wallpapers${NORMAL}"
    echo -e "    - ${MAGENTA}~/Documents/${username}${NORMAL}"
    mkdir -p ~/Music
    mkdir -p ~/Documents
    mkdir -p ~/Pictures/wallpapers/randomwallpaper
    mkdir -p ~/Documents/${username}

    # Copy the wallpapers
    echo -e "Copying all ${MAGENTA}wallpapers${NORMAL}"
    cp -r wallpapers/* ~/Pictures/wallpapers/

    # Get the hardware configuration
    echo -e "Copying ${MAGENTA}/etc/nixos/hardware-configuration.nix${NORMAL} to ${MAGENTA}./hosts/${HOST}/${NORMAL}\n"
    cp /etc/nixos/hardware-configuration.nix hosts/${HOST}/hardware-configuration.nix

    # Environment variable setup reminder
    if [[ $SECRETS_METHOD == "env" ]]; then
        echo -e "${YELLOW}Remember to run:${NORMAL} ${GREEN}source .env${NORMAL}"
        echo -en "Have you sourced the .env file? "
        confirm
    fi

    # Last Confirmation
    echo -en "You are about to start the system build, do you want to process ? "
    confirm

    # Build the system (flakes + home manager)
    echo -e "\nBuilding the system...\n"
    sudo nixos-rebuild switch --flake .#${HOST}
}

print_post_install() {
    echo -e "\n${GREEN}Installation completed!${NORMAL}\n"

    if [[ $SECRETS_METHOD == "file" ]]; then
        echo -e "${YELLOW}Important security notes:${NORMAL}"
        echo -e "- Your credentials are stored in ${MAGENTA}secrets.nix${NORMAL}"
        echo -e "- This file is git-ignored for security"
        echo -e "- Make sure to backup this file securely"
    else
        echo -e "${YELLOW}Environment variables method:${NORMAL}"
        echo -e "- Your .env file contains your credentials"
        echo -e "- This file is git-ignored for security"
        echo -e "- Remember to ${GREEN}source .env${NORMAL} in future sessions"
    fi

    echo -e "\n${GREEN}Next steps:${NORMAL}"
    echo -e "1. Reboot your system"
    echo -e "2. Configure your browser and other personal preferences"
    echo -e "3. Set up SSH keys if needed"
    echo -e "\nFor more information, see: ${CYAN}SECRETS.md${NORMAL}"
}

main() {
    init

    print_header

    get_secrets_method
    get_user_info
    get_wifi_info
    configure_secrets

    get_host
    aseprite
    install

    print_post_install
}

main && exit 0
