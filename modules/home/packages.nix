{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    reposync # repository synchronization TUI (via overlay)

    ## CLI utility
    # ani-cli # cli tool for anime
    aoc-cli # Advent of Code command-line tool
    # binsider # binary analysis tool
    # bitwise # cli tool for bit / hex manipulation
    # caligula # User-friendly, lightweight TUI for disk imaging
    chatterino7
    dconf-editor # GUI for dconf
    docfd # TUI multiline fuzzy document finder
    easyeffects # audio effects
    eza # ls replacement
    # entr # perform action when file change
    fd # find replacement
    # ffmpeg # video / audio processing
    ffmpeg-full
    ffsend # file sharing
    lazydocker # Docker management TUI
    # gtt # google translate TUI
    # gifsicle # gif utility
    gtrash # rm replacement, put deleted files in system trash
    # hexdump # hex viewer
    # htop # system monitor
    imv # image viewer
    viu # terminal image viewer
    killall # kill processes by name
    libnotify # notification library
    man-pages # extra man pages
    mimeo # open files based on mime type
    mpv # video player
    ncdu # disk space
    nitch # system fetch util
    openssl # ssl utility
    onefetch # fetch utility for git repo
    pamixer # pulseaudio command line mixer
    playerctl # controller for media players
    poweralertd # battery alert
    programmer-calculator
    streamlink # extract and play streaming content
    swappy # snapshot editing tool
    tdf # cli pdf viewer
    treefmt # project formatter
    tldr # tldr pages
    # todo # cli todo list
    toipe # typing test in the terminal
    ttyper # cli typing test
    valgrind # c memory analyzer
    # watchman  # watch files and run command when they change
    wavemon # monitoring for wireless network devices
    wl-clipboard # clipboard utils for wayland (wl-copy, wl-paste)
    woomer # wallpaper manager
    # yt-dlp-light # youtube-dl fork
    xdg-utils # xdg utils
    xxd # hex viewer

    # GStreamer and plugins are defined in browser.nix
    # VA-API drivers are configured in core/hardware.nix

    ## CLI
    cbonsai # terminal screensaver
    cmatrix # terminal screensaver
    pipes # terminal screensaver
    sl # terminal train animation
    tty-clock # terminal clock

    # batgrep tests fail in Nix sandbox due to filesystem restrictions
    (bat-extras.batgrep.overrideAttrs (_oldAttrs: {
      doCheck = false;
    }))

    ## Virtualization GUI
    virt-manager # virtual machine manager
    virt-viewer # virtual machine viewer

    ## GUI Apps
    audacity # audio editor
    bleachbit # cache cleaner
    discord # chat client
    filezilla # ftp client
    gimp # image editor
    gnome-disk-utility
    # ldtk # 2D level editor
    # tiled # tile map editor
    libreoffice # office suite
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

    # Password Managers
    _1password-gui # 1password
    _1password-cli
    # bitwarden # bitwarden
  ];
}
