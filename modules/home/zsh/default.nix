# Zsh configuration
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # FZF-Tab plugin (must load before autosuggestions/syntax highlighting)
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    # Completion initialization and FZF-Tab styles
    completionInit = ''
      # Load Zsh modules
      # zmodload zsh/zle
      # zmodload zsh/zpty
      # zmodload zsh/complist

      # Initialize colors
      autoload -Uz colors
      colors

      # Initialize completion system
      # autoload -U compinit
      # compinit
      _comp_options+=(globdots)

      # Load edit-command-line for ZLE
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey "^e" edit-command-line

      # General completion behavior
      zstyle ':completion:*' completer _extensions _complete _approximate

      # Use cache
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

      # Complete the alias
      zstyle ':completion:*' complete true

      # Autocomplete options
      zstyle ':completion:*' complete-options true

      # Completion matching control
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' keep-prefix true

      # Group matches and describe
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-grouped false
      zstyle ':completion:*' list-separator '''
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*:matches' group 'yes'
      zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
      zstyle ':completion:*:messages' format '%d'
      zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
      zstyle ':completion:*:descriptions' format '[%d]'

      # Colors
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Directories
      zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
      zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
      zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
      zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*' squeeze-slashes true

      # Sort
      zstyle ':completion:*' sort false
      zstyle ":completion:*:git-checkout:*" sort false
      zstyle ':completion:*' file-sort modification
      zstyle ':completion:*:eza' sort false
      zstyle ':completion:complete:*:options' sort false
      zstyle ':completion:files' sort false

      # fzf-tab
      zstyle ':fzf-tab:*' use-fzf-default-opts yes
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'eza --icons  -a --group-directories-first -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-pad 4
      zstyle ':fzf-tab:*' fzf-min-height 100
      zstyle ':fzf-tab:*' switch-group ',' '.'
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Convenience
      c = "clear";
      cd = "z"; # zoxide
      tt = "gtrash put";
      nano = "micro";
      diff = "delta --diff-so-fancy --side-by-side";
      less = "bat";
      y = "yazi";
      py = "python";
      icat = "viu";
      dsize = "du -hs";
      pdf = "tdf";
      open = "xdg-open";
      space = "ncdu";

      # Modern replacements
      ls = "eza --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons";
      cat = "bat";

      # File listing (eza)
      l = "eza --icons -a --group-directories-first -1";
      ll = "eza --icons -a --group-directories-first -1 --long --no-user";
      tree = "eza --icons --tree --group-directories-first";

      # Git shortcuts are in git.nix (comprehensive set with lazygit, onefetch, etc.)

      # NixOS management
      cdnix = "cd ~/Development/shifttab.nix";
      ns = "sudo nixos-rebuild switch --flake ~/Development/shifttab.nix --impure";
      nrs = "sudo nixos-rebuild switch --flake .";
      nrt = "sudo nixos-rebuild test --flake .";
      nd = "nix develop";
      nb = "nix build";
      nfu = "nix flake update";
      hms = "home-manager switch --flake ~/Development/shifttab.nix";

      # Backup aliases (backup-repos-logs defined in backup-repos.nix module)
      backup-repos-now = "systemctl --user start backup-repos.service";
      backup-repos-status = "systemctl --user status backup-repos.service";
      backup-repos-timer = "systemctl --user list-timers backup-repos.timer";
    };

    initContent = ''
      # Environment and Shell Options
      DISABLE_AUTO_UPDATE=true
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"

      # Fix helm ALSA issues in WSL
      export ALSA_CARD=0
      export SDL_AUDIODRIVER=dummy

      # WSL-specific fixes for Windows Terminal compatibility
      if [[ -n "$WSL_DISTRO_NAME" ]]; then
        # Disable zsh-autosuggestions async mode to prevent
        # "No handler installed for fd N" errors caused by file descriptor
        # races during rapid prompt redraws (oh-my-posh hooks + zoxide cd).
        unset ZSH_AUTOSUGGEST_USE_ASYNC

        # Explicitly disable mouse tracking modes that Windows Terminal may
        # activate but not properly consume, causing raw escape sequence spam
        # (e.g. "35,71;45M..." floods on directory change).
        # Disable: X10 (9), VT200 (1000), button-event (1002), any-event (1003),
        #          SGR extended (1006)
        printf '\e[?9l\e[?1000l\e[?1002l\e[?1003l\e[?1006l'
      fi

      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups
      setopt hist_ignore_dups
      setopt hist_find_no_dups
      setopt hist_expire_dups_first
      setopt hist_verify

      # Set GPG_TTY for GPG agent (required for commit signing)
      export GPG_TTY=$(tty)

      # Tell the running gpg-agent about the current TTY so pinentry
      # can attach to it (fallback when GUI pinentry is unavailable)
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true

      # SSH agent socket discovery: GNOME Keyring (gcr-ssh-agent) on all hosts
      # Desktop: started by graphical-session-pre.target (Hyprland)
      # WSL:     started by keyring-wsl.nix systemd user service
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        if [[ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]]; then
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
        fi
      fi

      # Auto-load SSH keys on first interactive login if the agent has none.
      # This prompts for the passphrase once (via seahorse on both desktop
      # and WSL) and caches the key in GNOME Keyring. Subsequent shells
      # skip the prompt.
      if [[ -o interactive ]] && [[ -n "$SSH_AUTH_SOCK" ]]; then
        if ! ssh-add -l &>/dev/null; then
          # Use (N) glob qualifier to enable NULL_GLOB for this pattern only
          # Load all id_ed25519_* keys (github, proxmox, etc.)
          for _keyfile in ~/.ssh/id_ed25519_*(N); do
            [[ -f "$_keyfile" && ! "$_keyfile" == *.pub ]] && ssh-add "$_keyfile" 2>/dev/null
          done
          unset _keyfile
        fi
      fi

      # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
      # - The first argument to the function ($1) is the base path to start traversal
      # - See the source code (completion.{bash,zsh}) for the details.
      _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
      }

      # Use fd to generate the list for directory completion
      _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
      }

      # Advanced customization of fzf options via _fzf_comprun function
      # - The first argument to the function is the name of the command.
      # - You should make sure to pass the rest of the arguments to fzf.
      _fzf_comprun() {
        local command=$1
        shift

        case "$command" in
          cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
          ssh)          fzf --preview 'dig {}'                   "$@" ;;
          *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
        esac
      }

      # Make sure that the terminal is in application mode when zle is active, since
      # only then values from $terminfo are valid.
      #
      # IMPORTANT: Skip this in WSL / Windows Terminal. The smkx (application keypad
      # mode) capability under WSL can trigger mouse-tracking reports that flood the
      # terminal with raw escape sequences (e.g. "35,71;45M..." spam on every cd).
      # Windows Terminal already sends correct key sequences without application mode,
      # so the guard is safe to skip there.
      if [[ -z "$WSL_DISTRO_NAME" ]] && (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
        function zle-line-init() {
          echoti smkx
        }
        function zle-line-finish() {
          echoti rmkx
        }
        zle -N zle-line-init
        zle -N zle-line-finish
      fi

      # Use emacs key bindings
      bindkey -e

      WORDCHARS='~!#$%^&*(){}[]<>?.+;-'

      ""{back,for}ward-word() WORDCHARS=$MOTION_WORDCHARS zle .$WIDGET
      zle -N backward-word
      zle -N forward-word

      # [PageUp] - Up a line of history
      if [[ -n "''${terminfo[kpp]}" ]]; then
        bindkey -M emacs "''${terminfo[kpp]}" up-line-or-history
        bindkey -M viins "''${terminfo[kpp]}" up-line-or-history
        bindkey -M vicmd "''${terminfo[kpp]}" up-line-or-history
      fi
      # [PageDown] - Down a line of history
      if [[ -n "''${terminfo[knp]}" ]]; then
        bindkey -M emacs "''${terminfo[knp]}" down-line-or-history
        bindkey -M viins "''${terminfo[knp]}" down-line-or-history
        bindkey -M vicmd "''${terminfo[knp]}" down-line-or-history
      fi

      # Start typing + [Up-Arrow] - fuzzy find history forward
      autoload -U up-line-or-beginning-search
      zle -N up-line-or-beginning-search

      bindkey -M emacs "^[[A" up-line-or-beginning-search
      bindkey -M viins "^[[A" up-line-or-beginning-search
      bindkey -M vicmd "^[[A" up-line-or-beginning-search
      if [[ -n "''${terminfo[kcuu1]}" ]]; then
        bindkey -M emacs "''${terminfo[kcuu1]}" up-line-or-beginning-search
        bindkey -M viins "''${terminfo[kcuu1]}" up-line-or-beginning-search
        bindkey -M vicmd "''${terminfo[kcuu1]}" up-line-or-beginning-search
      fi

      # Start typing + [Down-Arrow] - fuzzy find history backward
      autoload -U down-line-or-beginning-search
      zle -N down-line-or-beginning-search

      bindkey -M emacs "^[[B" down-line-or-beginning-search
      bindkey -M viins "^[[B" down-line-or-beginning-search
      bindkey -M vicmd "^[[B" down-line-or-beginning-search
      if [[ -n "''${terminfo[kcud1]}" ]]; then
        bindkey -M emacs "''${terminfo[kcud1]}" down-line-or-beginning-search
        bindkey -M viins "''${terminfo[kcud1]}" down-line-or-beginning-search
        bindkey -M vicmd "''${terminfo[kcud1]}" down-line-or-beginning-search
      fi

      # [Ctrl-Delete] - delete whole forward-word
      bindkey -M emacs '^[[3;5~' kill-word
      bindkey -M viins '^[[3;5~' kill-word
      bindkey -M vicmd '^[[3;5~' kill-word

      # [Ctrl-RightArrow] - move forward one word
      bindkey -M emacs '^[[1;5C' forward-word
      bindkey -M viins '^[[1;5C' forward-word
      bindkey -M vicmd '^[[1;5C' forward-word
      # [Ctrl-LeftArrow] - move backward one word
      bindkey -M emacs '^[[1;5D' backward-word
      bindkey -M viins '^[[1;5D' backward-word
      bindkey -M vicmd '^[[1;5D' backward-word

      bindkey '\ew' kill-region                             # [Esc-w] - Kill from the cursor to the mark
      bindkey -s '\el' 'ls\n'                               # [Esc-l] - run command: ls
      bindkey ' ' magic-space                               # [Space] - don't do history expansion

      # Edit the current command line in $EDITOR
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '\C-x\C-e' edit-command-line

      # file rename magick
      bindkey "^[m" copy-prev-shell-word

      # This will be our new default `ctrl+w` command
      my-backward-delete-word() {
          # Copy the global WORDCHARS variable to a local variable. That way any
          # modifications are scoped to this function only
          local WORDCHARS=$WORDCHARS
          # Use bash string manipulation to remove `:` so our delete will stop at it
          WORDCHARS="''${WORDCHARS//:}"
          # Use bash string manipulation to remove `/` so our delete will stop at it
          WORDCHARS="''${WORDCHARS//\/}"
          # Use bash string manipulation to remove `.` so our delete will stop at it
          WORDCHARS="''${WORDCHARS//.}"
          WORDCHARS="''${WORDCHARS//-}"
          # zle <widget-name> will run an existing widget.
          zle backward-delete-word
      }
      # `zle -N` will create a new widget that we can use on the command line
      zle -N my-backward-delete-word
      # bind this new widget to `ctrl+w`
      bindkey '^W' my-backward-delete-word

      # Path additions
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # Direnv for directory-based environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Zoxide smart cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
