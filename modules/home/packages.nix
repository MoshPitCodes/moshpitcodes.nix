{ inputs, pkgs, ... }:
let
  _2048 = pkgs.callPackage ../../pkgs/2048/default.nix { };
in
{
  home.packages = (
    with pkgs;
    [
      _2048 # 2048 game

      ## CLI utility
      ani-cli # cli tool for anime
      aoc-cli # Advent of Code command-line tool
      binsider # binary analysis tool
      bitwise # cli tool for bit / hex manipulation
      caligula # User-friendly, lightweight TUI for disk imaging
      chatterino7
      dconf-editor # GUI for dconf
      docfd # TUI multiline fuzzy document finder
      eza # ls replacement
      entr # perform action when file change
      fd # find replacement
      ffmpeg # video / audio processing
      ffsend # file sharing
      file # Show file information
      gtt # google translate TUI
      gifsicle # gif utility
      gtrash # rm replacement, put deleted files in system trash
      hexdump # hex viewer
      htop # system monitor
      imv # image viewer
      jq # JSON processor
      killall # kill processes by name
      libnotify
      man-pages # extra man pages
      mimeo # open files based on mime type
      mpv # video player
      ncdu # disk space
      nitch # systhem fetch util
      nixd # nix lsp
      nixfmt-rfc-style # nix formatter
      openssl # ssl utility
      onefetch # fetch utility for git repo
      pamixer # pulseaudio command line mixer
      playerctl # controller for media players
      poweralertd # battery alert
      programmer-calculator
      ripgrep # grep replacement
      shfmt # bash formatter
      swappy # snapshot editing tool
      tdf # cli pdf viewer
      tree # tree viewer
      treefmt # project formatter
      tldr # tldr pages
      tmux # terminal multiplexer
      todo # cli todo list
      toipe # typing test in the terminal
      ttyper # cli typing test
      unzip # zip utility
      valgrind # c memory analyzer
      wavemon # monitoring for wireless network devices
      wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
      wget # download utility
      woomer # wallpaper manager
      # yt-dlp-light # youtube-dl fork
      xdg-utils # xdg utils
      xxd # hex viewer
      zip # zip utility

      ## CLI
      cbonsai # terminal screensaver
      cmatrix # terminal screensaver
      pipes # terminal screensaver
      sl # terminal train animation
      tty-clock # terminal clock

      ## GUI Apps
      audacity # audio editor
      bleachbit # cache cleaner
      filezilla # ftp client
      gimp # image editor
      gnome-disk-utility
      ldtk # 2D level editor
      tiled # tile map editor
      libreoffice # office suite
      nix-prefetch-github
      obs-studio # screen recording
      pavucontrol # pulseaudio volume controle (GUI)
      # pitivi # video editing
      gnome-calculator # calculator
      mission-center # GUI resources monitor
      soundwireserver # audio streaming
      thunderbird # email client
      vlc # media player
      winetricks # wine helper
      wineWowPackages.wayland # wine
      zenity # GUI dialogs

      # C / C++
      gcc # C compiler
      gdb # C debugger
      gnumake # C build tool

      # Password Managers
      # _1password-gui # 1password
      # bitwarden # bitwarden

      inputs.alejandra.defaultPackage.${system}
    ]
  );
}
