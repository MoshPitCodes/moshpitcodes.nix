{ pkgs, inputs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.file.".config/nvf/init.lua".text = ''
    -- User nvf configuration
    -- Add any custom Lua configuration here
  '';

  programs.nvf = {
    enable = true;
    
    settings.vim.extraPackages = with pkgs; [
      nixd # Nix language server
      nixfmt-rfc-style # Nix formatter
    ];

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      theme = {
        enable = true;
        name = "rose-pine";
        style = "main";
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

        clang.enable = true;
        css.enable = true;
        go.enable = true;
        html.enable = true;
        java.enable = true;
        lua.enable = true;
        nix.enable = true;
        python.enable = true;
        rust.enable = true;
        ts.enable = true;
        yaml.enable = true;
        zig.enable = true;

      };

      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;

        highlight-undo.enable = true;
        indent-blankline.enable = true;

        # Fun
        # cellular-automaton.enable = false;
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
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

      dashboard = {
        dashboard-nvim.enable = true;
        alpha.enable = true;
      };

      notify = {
        nvim-notify = {
          enable = true;
          setupOpts = {
            background_colour = "#191724";
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
