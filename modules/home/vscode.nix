# VS Code editor (Everforest theme)
# LSP configuration is centralized in language-servers.nix
{ pkgs, lspLanguages, ... }:
let
  vscodeExtensions = import ./vscode-extensions.nix { inherit pkgs; };

  mcpConfigContent = builtins.toJSON {
    servers = {
      fetch = {
        type = "stdio";
        command = "uvx";
        args = [ "mcp-server-fetch" ];
      };
    };
  };
in
{
  xdg.configFile."Code/User/mcp.json" = {
    text = mcpConfigContent;
    onChange = ''
      if [ -L "$HOME/.config/Code/User/mcp.json" ]; then
        cp -f "$HOME/.config/Code/User/mcp.json" "$HOME/.config/Code/User/mcp.json.tmp"
        rm -f "$HOME/.config/Code/User/mcp.json"
        mv "$HOME/.config/Code/User/mcp.json.tmp" "$HOME/.config/Code/User/mcp.json"
        chmod u+w "$HOME/.config/Code/User/mcp.json"
      fi
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = vscodeExtensions.vscodeExtensions.packages;
      userSettings = {
        "update.mode" = "none";
        "extensions.ignoreRecommendations" = true;
        "extensions.autoUpdate" = true;
        "window.titleBarStyle" = "custom";
        "breadcrumbs.enabled" = false;

        "github.copilot.enable" = true;
        "github.copilot.chat.enable" = true;

        editor = {
          fontFamily = "'FiraCode Nerd Font', 'monospace', monospace";
          fontLigatures = true;
          fontSize = 16;
          formatOnPaste = true;
          formatOnSave = true;
          formatOnType = true;
          minimap.enabled = false;
          mouseWheelZoom = true;
          renderControlCharacters = false;
          scrollbar = {
            horizontal = "hidden";
            horizontalScrollbarSize = 2;
            vertical = "hidden";
            verticalScrollbarSize = 2;
          };
        };

        explorer = {
          autoReveal = false;
          confirmDragAndDrop = false;
          confirmDelete = false;
          enableDragAndDrop = true;
          revealFirst = true;
          sortOrder = "default";
          openEditors.visible = 0;
        };

        extensions = {
          autoCheckUpdates = false;
          autoUpdate = true;
          ignoreRecommendations = true;
        };

        files = {
          autoGuessEncoding = true;
          autoSave = "onWindowChange";
          autoSaveDelay = 1000;
          encoding = "utf8";
          exclude = {
            "**/.git/objects/**" = true;
            "**/.git/subtree-cache/**" = true;
            "**/node_modules/**" = true;
            "**/vendor/**" = true;
          };
          insertFinalNewline = true;
          trimTrailingWhitespace = true;
        };

        git = {
          confirmSync = false;
          enableSmartCommit = true;
          ignoreLimitWarning = true;
        };

        terminal = {
          integrated = {
            cursorBlinking = true;
            cursorStyle = "line";
            fontFamily = "'FiraCode Nerd Font'";
            fontSize = 16;
            lineHeight = 1.2;
            scrollback = 10000;
            shellIntegration.enabled = true;
          };
        };

        workbench = {
          activityBar.location = "default";
          colorTheme = "Everforest Dark";
          editor = {
            limit = {
              enabled = true;
              perEditorGroup = true;
              value = 10;
            };
            showTabs = "multiple";
          };
          iconTheme = "material-icon-theme";
          startupEditor = "none";
          statusBar.visible = true;
        };
      }
      # Language server settings (synchronized with language-servers.nix)
      // (
        if lspLanguages.go then
          {
            go.useLanguageServer = true;
          }
        else
          { }
      )
      // (
        if lspLanguages.nix then
          {
            nix = {
              formatterPath = "${pkgs.nixfmt}/bin/nixfmt";
              enableLanguageServer = true;
              serverPath = "${pkgs.nixd}/bin/nixd";
              serverSettings = {
                nixd = {
                  formatting.command = [ "nixfmt" ];
                };
              };
            };
          }
        else
          { }
      )
      // (
        if lspLanguages.zig then
          {
            zig = {
              checkForUpdate = false;
              path = "zig";
            };
          }
        else
          { }
      );

      keybindings = [
        {
          key = "ctrl+q";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+s";
          command = "workbench.action.files.saveFiles";
        }
        {
          key = "ctrl+i";
          command = "composerMode.agent";
        }
      ];
    };
  };
}
