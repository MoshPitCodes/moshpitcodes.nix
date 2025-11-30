{ pkgs, ... }:
let
  # Import shared VSCode extension definitions
  vscodeExtensions = import ./vscode-extensions.nix { inherit pkgs; };

  # MCP configuration content
  mcpConfigContent = builtins.toJSON {
    inputs = [
      {
        type = "promptString";
        id = "github_token";
        description = "GitHub Personal Access Token";
        password = true;
      }
    ];
    servers = {
      github = {
        type = "stdio";
        command = "docker";
        args = [
          "-i"
          "--rm"
          "-e"
          "GITHUB_PERSONAL_ACCESS_TOKEN"
          "ghcr.io/github/github-mcp-server"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${input:github_token}";
        };
      };
      fetch = {
        type = "stdio";
        command = "uvx";
        args = [ "mcp-server-fetch" ];
      };
    };
  };
in
{
  # Create MCP configuration file as a writable file
  xdg.configFile."Code/User/mcp.json" = {
    text = mcpConfigContent;
    onChange = ''
      # Copy the file to make it writable (not a symlink)
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
      # Use shared extension definitions
      extensions = vscodeExtensions.vscodeExtensions.packages;
      userSettings = {
        "update.mode" = "none"; # This stuff fixes VSCode freaking out when theres an update
        "extensions.ignoreRecommendations" = true; # This stuff fixes VSCode freaking out when theres an update
        "extensions.autoUpdate" = true; # This stuff fixes VSCode freaking out when theres an update
        "window.titleBarStyle" = "custom"; # see https://github.com/NixOS/nixpkgs/issues/246509

        "breadcrumbs.enabled" = false;

        # Enable GitHub Copilot.cpptools

        "github.copilot.enable" = true;
        "github.copilot.chat.enable" = true;
        "github.copilot.chat.enableExperimental" = true;
        "github.copilot.chat.enableExperimentalUI" = true;

        editor = {
          fontFamily = "'Maple Mono NF', 'SymbolsNerdFont', 'monospace', monospace";
          fontLigatures = true;
          fontSize = 16;
          formatOnPaste = true;
          formatOnSave = true;
          formatOnType = true;
          minimap.enabled = false;
          mouseWheelZoom = true;
          renderControlCharacters = false;
          scrollbar.horizontal = "hidden";
          scrollbar.horizontalScrollbarSize = 2;
          scrollbar.vertical = "hidden";
          scrollbar.verticalScrollbarSize = 2;
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
          showRecommendationsOnlyOnDemand = true;
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
            "**/.hg/store/**" = true;
            "**/.svn/wc.db" = true;
          };
          insertFinalNewline = true;
          trimTrailingWhitespace = true;
          format = {
            enable = true;
            insertFinalNewline = true;
            trimTrailingWhitespace = true;
          };
          quickSuggestions = {
            comments = false;
            strings = true;
            other = true;
          };
          quickSuggestionsDelay = 100;
          renameOnType = true;
          search = {
            followSymlinks = true;
            useRipgrep = true;
          };
          showHiddenFiles = true;
          showResolvedSymlinks = true;
          sortOrder = "default";
          tabSize = 4;
          useExperimentalFileWatcher = true;
          useExperimentalSearch = true;
          useExperimentalTreeSitterParser = true;
        };

        git = {
          confirmSync = false;
          enableSmartCommit = true;
          ignoreLimitWarning = true;
          showPushSuccessNotification = false;
          showUncommittedChangesResourceCount = true;
          smartCommitChanges = true;
          smartCommitChangesPrompt = false;
          useEditorAsCommitInput = true;
        };

        markdown = {
          autoCloseBrackets = true;
          autoClosingBrackets = "always";
          autoClosingQuotes = "always";
          codeLens = {
            actions = true;
            references = true;
            definitions = true;
          };
          colorDecorators = true;
          comments = {
            ignoreEmptyLines = false;
            ignoreEmptyComments = false;
          };
          format.enable = true;
          format.insertSpaces = true;
          format.tabSize = 4;
          hover.enabled = true;
          preview.autoShow = true;
          preview.scrollPreviewWithEditor = true;
          preview.scrollEditorWithPreview = true;
        };

        material-icon-theme = {
          folders = "classic";
        };

        terminal = {
          integrated = {
            allowWorkspaceShellCommand = true;
            cursorBlinking = true;
            cursorStyle = "line";
            fontFamily = "'Maple Mono NF', 'SymbolsNerdFont'";
            fontSize = 16;
            lineHeight = 1.2;
            scrollback = 10000;
            shellIntegration.enabled = true;
            shellIntegration.autoDetect = true;
            shellIntegration.autoDetectNixShell = true;
          };
        };

        vsicons = {
          dontShowNewVersionMessage = true;
        };

        windows = {
          menuBarVisibility = "show";
        };

        workbench = {
          activityBar.location = "default";
          colorTheme = "Gruvbox Dark Hard";
          editor.limit.enabled = true;
          editor.limit.perEditorGroup = true;
          editor.limit.value = 10;
          editor.showTabs = "multiple";
          iconTheme = "gruvbox-material-icon-theme";
          layoutControl.enabled = false;
          layoutControl.type = "menu";
          startupEditor = "none";
          statusBar.visible = true;
        };

        prettier = {
          arrowParens = "avoid";
          bracketSpacing = false;
          htmlWhitespaceSensitivity = "ignore";
          printWidth = 80;
          proseWrap = "preserve";
          trailingComma = "es5";
          tabWidth = 4;
          semi = false;
          singleQuote = true;
          useTabs = true;
          endOfLine = "auto";
          quoteProps = "as-needed";
          bracketSameLine = false;
          singleAttributePerLine = false;
        };

        "C_Cpp.autocompleteAddParentheses" = true;
        "C_Cpp.clang_format_sortIncludes" = true;
        "C_Cpp.default.browse.path" = [''
          ''${workspaceFolder}/**
        ''];
        "C_Cpp.default.cStandard" = "gnu11";
        "C_Cpp.doxygen.generatedStyle" = "/**";
        "C_Cpp.formatting" = "clangFormat";
        "C_Cpp.inlayHints.parameterNames.hideLeadingUnderscores" = false;
        "C_Cpp.intelliSenseCacheSize" = 2048;
        "C_Cpp.intelliSenseMemoryLimit" = 2048;
        "C_Cpp.intelliSenseUpdateDelay" = 500;
        "C_Cpp.vcFormat.indent.caseLabels" = true;
        "C_Cpp.vcFormat.newLine.beforeCatch" = false;
        "C_Cpp.vcFormat.newLine.beforeElse" = false;
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.block" = "sameLine";
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.function" = "sameLine";
        "C_Cpp.vcFormat.newLine.beforeOpenBrace.type" = "sameLine";
        "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyFunction" = true;
        "C_Cpp.vcFormat.newLine.closeBraceSameLine.emptyType" = true;
        "C_Cpp.vcFormat.space.beforeEmptySquareBrackets" = true;
        "C_Cpp.vcFormat.space.betweenEmptyBraces" = true;
        "C_Cpp.vcFormat.space.betweenEmptyLambdaBrackets" = true;
        "C_Cpp.workspaceParsingPriority" = "medium";

        # Golang
        go = {
          languageServerExperimentalFeatures = {
            diagnostics = true;
            documentLink = true;
            documentSymbol = true;
            formatting = true;
            goToDefinition = true;
            hover = true;
            references = true;
            rename = true;
            signatureHelp = true;
          };
          useLanguageServer = true;
        };

        # JSON
        "[jsonc]" = {
          editor.defaultFormatter = "esbenp.prettier-vscode";
        };

        yaml = {
          format = {
            enable = true;
            bracketSpacing = false;
            singleQuote = true;
            tabSize = 4;
            useTabs = false;
          };
          validate = true;
          schemas = {
            "https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/github-workflow.json" =
              [
                ".github/workflows/*"
              ];
            "https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/pre-commit-config.json" =
              [
                ".pre-commit-config.yaml"
              ];
          };
        };

        zig = {
          checkForUpdate = false;
          zls = {
            path = "zls";
            args = [ "--stdio" ];
            enable = true;
            enableInlayHints = false;
            enableInlayHintsForTypes = false;
            enableInlayHintsForParameterNames = false;
            enableInlayHintsForParameterTypes = false;
            enableInlayHintsForReturnTypes = false;
          };
          path = "zig";
          revealOutputChannelOnFormattingError = false;
          format = {
            enable = true;
            insertSpaces = true;
            tabSize = 4;
          };
          linting = {
            enable = true;
            run = "onType";
          };
          validate = true;
          languageServer = {
            enable = true;
            path = "zls";
            args = [ "--stdio" ];
          };
          languageServerExperimentalFeatures = {
            diagnostics = true;
            documentLink = true;
            documentSymbol = true;
            formatting = true;
            goToDefinition = true;
            hover = true;
            references = true;
            rename = true;
            signatureHelp = true;
          };
          languageServerSettings = {
            zig = {
              buildMode = "Debug";
              buildOptions = [ "--build-mode=Debug" ];
              cachePath = "${pkgs.zig}/share/zig";
              cachePathEnabled = true;
              cachePathMode = "auto";
              checkOnSave = {
                enable = true;
                command = "check";
                args = [ "--all" ];
                onType = false;
              };
              formatOnSave = true;
              lintOnSave = true;
            };
          };
        };

        # Nix
        nix = {
          formatterPath = "${pkgs.nixfmt-rfc-style}/bin/nixfmt-rfc-style";
          enableLanguageServer = true;
          enableNixShellIntegration = {
            enable = true;
            autoDetect = true;
            autoDetectNixShell = true;
          };
          serverPath = "${pkgs.nixd}/bin/nixd";
          serverSettings = {
            nixd = {
              formatting = {
                command = [ "nixfmt-rfc-style" ];
              };
              options = {
                nixos = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.laptop.options";
                };
                home-manager = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.laptop.options";
                };
              };
            };
          };
          languageServerExperimentalFeatures = {
            diagnostics = true;
            documentLink = true;
            documentSymbol = true;
            formatting = true;
            goToDefinition = true;
            hover = true;
            references = true;
            rename = true;
            signatureHelp = true;
          };
          languageServerSettings = {
            nix = {
              cachePathEnabled = false;
              cachePathMode = "auto";
              checkOnSave.enable = false;
              formatOnSave.enable = false;
              lintOnSave.enable = false;
              useLanguageServer.enable = true;
            };
          };
        };
      };
      # Keybindings
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
        {
          key = "shift+enter";
          command = "claude-code.submitMessage";
          when = "inputFocus && claudeCodeInputFocused";
        }
      ];
    };
  };
}
