{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        # Must be before plugins that wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

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

    initContent = lib.mkBefore ''
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

      # SSH agent socket discovery (ordered by preference):
      # 1. gpg-agent SSH socket (WSL: enableSSHSupport=true in wsl-overrides.nix)
      # 2. gcr-ssh-agent socket (Desktop: GNOME Keyring with graphical session)
      if [[ -z "$SSH_AUTH_SOCK" ]]; then
        _gpg_ssh_sock="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"
        if [[ -S "$_gpg_ssh_sock" ]]; then
          export SSH_AUTH_SOCK="$_gpg_ssh_sock"
        elif [[ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]]; then
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
        fi
        unset _gpg_ssh_sock
      fi

      # Auto-load SSH keys on first interactive login if the agent has none.
      # This prompts for the passphrase once (via pinentry-gnome3 on WSL,
      # seahorse on desktop) and caches the key for the configured TTL
      # (8 hours in wsl-overrides.nix). Subsequent shells skip the prompt.
      if [[ -o interactive ]] && [[ -n "$SSH_AUTH_SOCK" ]]; then
        if ! ssh-add -l &>/dev/null; then
          for _keyfile in ~/.ssh/id_ed25519_*; do
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

      # Initialize zoxide
      eval "$(zoxide init zsh)"
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };
}
