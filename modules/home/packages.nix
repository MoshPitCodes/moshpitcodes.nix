# User packages
{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      # CLI tools
      reposync
      ripgrep
      fd
      eza
      jq
      yq
      tree
      unzip
      zip
      aoc-cli
      docfd
      ffsend
      lazydocker
      gtrash
      viu
      nitch
      openssl
      mimeo
      programmer-calculator
      streamlink
      tdf
      treefmt
      toipe
      ttyper
      valgrind
      wavemon
      woomer
      xxd

      # System tools
      htop
      ncdu
      killall
      man-pages
      xdg-utils
      onefetch
      dconf-editor
      gnome-disk-utility
      zenity
      rofi
      rofi-power-menu

      # Development
      nil
      nixfmt

      # Wayland utilities
      wl-clipboard
      wl-clip-persist
      cliphist
      slurp
      grimblast
      wf-recorder

      # Desktop utilities
      pavucontrol
      networkmanagerapplet
      playerctl
      brightnessctl
      hyprpicker
      pamixer
      libnotify
      poweralertd

      # Desktop environment
      waybar
      swaynotificationcenter
      nautilus

      # Media
      ffmpeg-full
      imv
      mpv
      easyeffects

      # Terminal fun
      cbonsai
      cmatrix
      pipes
      sl
      tty-clock

      # batgrep with disabled checks
      (bat-extras.batgrep.overrideAttrs (_oldAttrs: {
        doCheck = false;
      }))

      # Virtualization
      virt-manager
      virt-viewer

      # GUI Applications
      aseprite
      audacity
      bleachbit
      chatterino7
      discord
      filezilla
      gimp
      libreoffice
      obs-studio
      gnome-calculator
      mission-center
      soundwireserver
      thunderbird
      vlc
      winetricks
      wineWow64Packages.wayland
      (bottles.override { removeWarningPopup = true; }) # Windows app runner with Wine (warning disabled for NixOS)

      # Password Managers
      _1password-gui
      _1password-cli

      # Virtualization icons
      adwaita-icon-theme

      # Fonts - all Nerd Fonts + extras
      twemoji-color-font
      noto-fonts-color-emoji
      fantasque-sans-mono
      maple-mono.NF
    ]
    ++ builtins.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts)
    ++ [

      # Modern CLI tools
      tokei
      dust
      duf
      procs
      bottom
      tealdeer
      zoxide
      httpie
      doggo
      sd
      choose
      hyperfine
      glow
      nix-tree
      nix-diff
      comma
    ];
}
