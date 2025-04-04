{ pkgs, ... }:
let
  jonathanharty.gruvbox-material-icon-theme = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "gruvbox-material-icon-theme";
      publisher = "JonathanHarty";
      version = "1.1.5";
      hash = "sha256-86UWUuWKT6adx4hw4OJw3cSZxWZKLH4uLTO+Ssg75gY=";
    };
  };
  ziglang_vscode-zig = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-zig";
      publisher = "ziglang";
      version = "0.6.7";
      hash = "sha256-l8pu348v2JUg/7+Qy5B41eyraPUj9WQ1WuW1aumgM9w=";
    };
  };

in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [

        # ---------------------------
        # Official Microsoft extensions
        # ---------------------------
        # C/C++ Intellisense
        ms-vscode.cpptools-extension-pack

        # C/C++ support
        ms-vscode.cpptools

        # C# support
        # ms-dotnettools.csdevkit

        # CMake support
        ms-vscode.cmake-tools

        # Makefile support
        ms-vscode.makefile-tools

        # MS Azure
        # ms-azure-devops.azure-pipelines
        # ms-azuretools.vscode-azurefunctions
        # ms-azuretools.vscode-azureresourcegroups
        # ms-azuretools.vscode-azuresql
        # ms-azuretools.vscode-cosmosdb
        # ms-azuretools.vscode-bicep
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools

        # python
        ms-python.python

        # python linting
        # ms-python.autopep8
        # ms-python.black-formatter
        # ms-python.flake8
        # ms-python.isort
        # ms-python.jedi
        # ms-python.pylance
        # ms-python.pylint
        # ms-python.vscode-pylance
        # ms-python.vscode-pylance-pack

        # VSCode Remote
        # ms-vscode-remote.remote-ssh
        # ms-vscode-remote.remote-ssh-edit
        # ms-vscode-remote.remote-wsl

        # VSCode Java debug
        # vscjava.vscode-java-debug
        # vscjava.vscode-java-pack
        # vscjava.vscode-java-test
        # vscjava.vscode-maven
        # vscjava.vscode-gradle

        # ---------------------------
        # 3rd party extensions
        # ---------------------------
        # ESLint
        dbaeumer.vscode-eslint

        # Github
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github

        # GitLens
        # eamodio.gitlens

        # Golang
        golang.go

        # Hashicorp
        hashicorp.hcl
        hashicorp.terraform # TODO: use terraform-lsp instead

        # Just
        # nefrob.vscode-just-syntax

        # Mermaid Diagrams
        bierner.markdown-mermaid

        # nix language
        jnoortheen.nix-ide

        # nix-shell support
        arrterian.nix-env-selector

        # OCaml
        ocamllabs.ocaml-platform

        # Prettier
        esbenp.prettier-vscode

        # ToDo highlighting
        jgclark.vscode-todo-highlight

        # YAML support by redhat
        redhat.ansible
        redhat.java
        redhat.vscode-yaml

        # Zig
        ziglang_vscode-zig

        # Markdown
        yzhang.markdown-all-in-one

        # Color theme
        jdinhlife.gruvbox

        # sainnhe.gruvbox-material
        jonathanharty.gruvbox-material-icon-theme
      ];
      userSettings = {
        "update.mode" = "none";
        "extensions.autoUpdate" = true; # This stuff fixes VSCode freaking out when theres an update
        "window.titleBarStyle" = "custom"; # see https://github.com/NixOS/nixpkgs/issues/246509

        "breadcrumbs.enabled" = false;

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
        "C_Cpp.default.browse.path" = [ ''''${workspaceFolder}/**'' ];
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
          # formatFlags = [ "-w" ];
          # formatTool = "gofmt";
          # useLanguageServer" = true;
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
          formatterPath = [
            "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"
            "${pkgs.nixfmt-rfc-style}/bin/nixfmt-rfc-style"
            "${pkgs.treefmt}/bin/treefmt"
            "--stdin"
            "{file}"
            "nix"
            "fmt"
            "--"
            "-"
          ];
          enableLanguageServer = true;
          enableNixShellIntegration = {
            enable = true;
            autoDetect = true;
            autoDetectNixShell = true;
          };
          serverPath = "nixd";
          serverSettings = {
            nixd = {
              formatting = {
                command = [ "nixfmt" ];
              };
              options = {
                nixos = {
                  expr = "(builtins.getFlake \"/absolute/path/to/flake\").nixosConfigurations.<name>.options";
                };
                home-manager = {
                  expr = "(builtins.getFlake \"/absolute/path/to/flake\").homeConfigurations.<name>.options";
                };
              };
            };
          };
          # languageServer = {
          #   enable = true;
          #   path = "nix-lsp";
          #   args = [ "--stdio" ];
          # };
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
              useLanguageServer.enable = false;
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
      ];
    };
  };
}
