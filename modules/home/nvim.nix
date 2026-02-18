# Neovim configuration with Everforest theme
# LSP configuration is centralized in language-servers.nix
{
  pkgs,
  inputs,
  lspLanguages,
  ...
}:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.file.".config/nvf/init.lua".text = ''
    -- User nvf configuration
    -- Add any custom Lua configuration here
  '';

  programs.nvf = {
    enable = true;

    # Extra packages are now managed in language-servers.nix

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      theme = {
        enable = true;
        name = "everforest";
        style = "medium"; # hard, medium, or soft
        transparent = true;
      };

      telescope.enable = true;

      spellcheck = {
        enable = true;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        trouble.enable = true;
        lspSignature.enable = true;
        otter-nvim.enable = false;
        nvim-docs-view.enable = false;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # Language enablement synchronized with language-servers.nix
        clang.enable = lspLanguages.c-cpp;
        css.enable = lspLanguages.css;
        go.enable = lspLanguages.go;
        html.enable = lspLanguages.html;
        java.enable = lspLanguages.java;
        lua.enable = lspLanguages.lua;
        nix.enable = lspLanguages.nix;
        python.enable = lspLanguages.python;
        rust.enable = lspLanguages.rust;
        ts.enable = lspLanguages.javascript-typescript;
        yaml.enable = lspLanguages.yaml;
        zig.enable = lspLanguages.zig;
      };

      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "auto";
        };
      };

      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;

      tabline = {
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false;
      };

      dashboard = {
        dashboard-nvim.enable = true;
        alpha.enable = true;
      };

      notify = {
        nvim-notify = {
          enable = true;
          setupOpts = {
            background_colour = "#2d353b"; # Everforest dark background
            render = "compact";
            timeout = 3000;
            top_down = true;
            stages = "fade_in_slide_out";
          };
        };
      };

      utility = {
        ccc.enable = false;
        vim-wakatime.enable = false;
        icon-picker.enable = false;
        surround.enable = false;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
          precognition.enable = false;
        };
        images = {
          image-nvim.enable = false;
        };
      };

      ui = {
        borders.enable = true;
        noice = {
          enable = true;
          setupOpts = {
            lsp = {
              signature = {
                enabled = false;
                auto_open = {
                  enabled = true;
                  trigger = true;
                  luasnip = true;
                  throttle = 50;
                };
              };
            };
          };
        };
        colorizer.enable = true;
        illuminate.enable = true;
        breadcrumbs = {
          enable = false;
          navbuddy.enable = false;
        };
        smartcolumn = {
          enable = true;
        };
        fastaction.enable = true;
      };

      session = {
        nvim-session-manager.enable = false;
      };

      comments = {
        comment-nvim.enable = true;
      };
    };
  };
}
