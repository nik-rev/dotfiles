{
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  ...
}:
{
  programs.helix = {
    defaultEditor = true;
    enable = true;
    package = inputs.helix.packages.${pkgs.system}.helix;

    settings =
      let
        keybindings = {
          tab.x = ":write-quit-all";
          space.i = ":toggle lsp.display-inlay-hints";
          x = "select_line_below";
          H = "@F)mi(";
          L = "@f(mi(";
          X = "select_line_above";
          S-left = "jump_backward";
          S-right = "jump_forward";
          w = "collapse_selection";
          ret = ":write";
          A-c = "copy_selection_on_prev_line";
          A-d = "@:e <C-r>%<C-w>";
          up = "select_textobject_inner";
          down = "select_textobject_around";
          left = "@[";
          right = "@]";
          C-j = "join_selections_space";
          # open lazygit
          C-g = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
          # newline without comment
          g.O = [
            "open_above"
            "delete_word_backward"
          ];
          g.o = [
            "open_below"
            "delete_word_backward"
          ];
        };
      in
      {
        theme = "catppuccin";
        editor = {
          default-yank-register = "+";
          auto-info = false;
          soft-wrap.enable = true;
          line-number = "relative";
          inline-diagnostics.cursor-line = "hint";
          cursorline = true;
          statusline = {
            left = [ ];
            center = [ ];
            right = [
              "spinner"
              "file-name"
              "diagnostics"
            ];
          };
          indent-guides = {
            character = "╎";
            skip-levels = 1;
            render = true;
          };
        };
        keys.select = keybindings // {
          backspace = "extend_to_word";
        };
        keys.normal = keybindings // {
          backspace = "goto_word";
          _ = "@vgs";
          "$" = "@vge";
        };
        # newline without comment
        keys.insert.A-ret = [
          "insert_newline"
          "delete_word_backward"
        ];
      };

    themes.catppuccin = {
      inherits = "catppuccin_mocha";
      "variable.other.member" = "teal";
      "function.macro" = "rosewater";

      "ui.cursor.primary.normal" = {
        fg = "base";
        bg = "rosewater";
      };

      "ui.cursor.normal" = {
        fg = "base";
        bg = "#b5a6a8";
      };

      # https://github.com/catppuccin/helix
      "ui.virtual.inlay-hint" = {
        fg = "surface2";
        bg = "mantle";
      };
      "ui.virtual.inlay-hint.parameter" = "subtext0";
      "ui.virtual.inlay-hint.type" = "subtext1";

      "function.builtin" = {
        fg = "blue";
        modifiers = [ "bold" ];
      };

      # https://github.com/catppuccin/helix/pull/58
      "markup.heading.1" = "red";
      "markup.heading.2" = "peach";
      "markup.heading.3" = "yellow";
      "markup.heading.4" = "green";
      "markup.heading.5" = "blue";
      "markup.heading.6" = "mauve";
      "markup.list" = "teal";
      "markup.bold" = {
        fg = "red";
        modifiers = [ "bold" ];
      };
      "markup.italic" = {
        fg = "red";
        modifiers = [ "italic" ];
      };
      "markup.link.text" = "lavender";
      "markup.raw" = "green";
      "markup.quote" = "pink";
    };

    languages = {
      language-server = {
        texlab.config.texlab = {
          build = {
            executable = "pdflatex";
            args = [
              "-synctex=1"
              "-interaction=nonstopmode"
              "-output-directory=build"
              "%f"
            ];
            onSave = true;
            forwardSearchAfter = true;
          };
          forwardSearch.executable = "zathura";
          forwardSearch.args = [
            "--synctex-forward"
            "%l:1:%f"
            "%p"
          ];
          chktex.onEdit = true;
        };
        rust-analyzer.config = {
          check.command = "clippy";
          # makes it work when in an integration-test
          # cargo.features = "all";
        };
        nginx = {
          command = "nginx-language-server";
          filetypes = [ "nginx" ];
          required-root-patterns = [ "nginx.conf" ];
        };
        # eslint = {
        #   args = [ "--stdio" ];
        #   command = "vscode-eslint-language-server";
        #   config.validate = "on";
        # };
        typescript-language-server = {
          required-root-patterns = [ "package.json" ];
          args = [ "--stdio" ];
        };
        deno = {
          command = "deno";
          args = [ "lsp" ];
          config.deno = {
            enable = true;
            lint = true;
          };
          required-root-patterns = [ "deno.*" ];
        };
        mdx = {
          command = "mdx-language-server";
          args = [ "--stdio" ];
        };
        tailwindcss = {
          command = lib.getExe pkgs-unstable.tailwindcss-language-server;
          args = [ "--stdio" ];
        };
        ruff = {
          command = lib.getExe pkgs-unstable.ruff;
        };
        gopls.config.gofumpt = true;
        astro-ls = {
          command = lib.getExe pkgs-unstable.nodePackages."@astrojs/language-server";
          args = [ "--stdio" ];
          config = {
            typescript = {
              tsdk = "${pkgs-unstable.typescript}/lib/node_modules/typescript/lib";
              environment = "node";
            };
          };
        };
      };

      grammar = [
        {
          name = "tera";
          source.git = "https://github.com/uncenter/tree-sitter-tera";
          source.rev = "main";
        }
      ];

      language =
        let
          prettier = lang: {
            command = lib.getExe pkgs-unstable.prettierd;
            args = [ lang ];
          };
        in
        map (language: language // { auto-format = true; }) ([
          {
            name = "astro";
            scope = "source.astro";
            injection-regex = "astro";
            file-types = [ "astro" ];
            roots = [
              "package.json"
              "astro.config.mjs"
            ];
            language-servers = [
              "astro-ls"
              "tailwindcss"
            ];
            formatter = {
              command = lib.getExe pkgs-unstable.nodePackages.prettier;
              args = [
                "--plugin"
                "prettier-plugin-astro"
                "--parser"
                "astro"
              ];
            };
          }
          {
            file-types = [ "tera" ];
            grammar = "tera";
            injection-regex = "tera";
            name = "tera";
            scope = "source.tera";
            auto-pairs = {
              "\"" = "\"";
              "'" = "'";
              "`" = "`";
              "(" = ")";
              "[" = "]";
              "{" = "}";
              "%" = "%";
            };
            block-comment-tokens = [
              {
                start = "{#";
                end = "#}";
              }
              {
                start = "{#-";
                end = "-#}";
              }
              {
                start = "{#";
                end = "-#}";
              }
              {
                start = "{#-";
                end = "#}";
              }
            ];
          }
          {
            name = "cpp";
            file-types = [
              "cpp"
              "cc"
              "cxx"
              "hpp"
              "hcc"
              "hxx"
            ];
            formatter.command = "clang-format";
          }
          {
            name = "typst";
            formatter.command = "typstyle";
          }
          {
            name = "latex";
          }
          {
            name = "c";
            file-types = [
              "c"
              "h"
            ];
            formatter.command = "clang-format";
          }
          # TODO: use nufmt to format nushell files when the formatter becomes available
          # {
          #   name = "nu";
          #   formatter.command = "nufmt";
          #   formatter.args = [ "--stdin" ];
          # }
          {
            name = "python";
            language-servers = [
              "pyright"
              "ruff"
            ];
          }
          {
            name = "typescript";
            formatter = prettier ".ts";
            language-servers = [
              "typescript-language-server"
              # "eslint"
              # "deno"
            ];
          }
          {
            name = "yaml";
            formatter = prettier ".yaml";
          }
          {
            name = "markdown";
            formatter = prettier ".md";
            language-servers = [
              "tailwindcss"
            ];
          }
          {
            name = "scss";
            formatter = prettier ".scss";
          }
          {
            name = "css";
            formatter = prettier ".css";
          }
          {
            name = "tsx";
            formatter = prettier ".tsx";
            language-servers = [
              "tailwindcss"
              "typescript-language-server"
              # "eslint"
            ];
            block-comment-tokens = [
              "{/*"
              "*/}"
            ];
          }
          {
            name = "jsx";
            formatter = prettier ".jsx";
          }
          {
            name = "json";
            formatter = prettier ".json";
          }
          {
            name = "toml";
            formatter.command = lib.getExe pkgs-unstable.taplo;
            formatter.args = [
              "format"
              "-"
            ];
          }
          {
            name = "html";
            formatter = prettier ".html";
          }
          {
            name = "c-sharp";
            formatter.command = lib.getExe pkgs-unstable.csharpier;
          }
          {
            name = "javascript";
            formatter = prettier ".js";
          }
          {
            name = "nix";
            formatter.command = lib.getExe pkgs-unstable.nixfmt-rfc-style;
          }
          {
            name = "lua";
            formatter.command = lib.getExe pkgs-unstable.stylua;
            formatter.args = [ "-" ];
          }
          {
            name = "bash";
            formatter.command = lib.getExe pkgs-unstable.shfmt;
          }
          {
            name = "haskell";
            formatter.command = lib.getExe pkgs-unstable.ormolu;
            formatter.args = [
              "--stdin-input-file"
              "."
            ];
          }
        ]);
    };
  };
}
