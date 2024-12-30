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
          x = "select_line_below";
          X = "select_line_above";
          S-left = "jump_backward";
          S-right = "jump_forward";
          w = "collapse_selection";
          ret = ":write";
          space.e = "file_browser_in_current_buffer_directory";
          space.E = "file_browser";
          D = "copy_selection_on_prev_line";
          up = "select_textobject_inner";
          down = "select_textobject_around";
          left = "@[";
          right = "@]";
          "`"."u" = "switch_to_uppercase";
          "`"."l" = "switch_to_lowercase";
          # delete two lines below
          C-j = [
            "extend_to_line_bounds"
            "extend_line_below"
            "delete_selection"
          ];
          # delete two lines above
          C-k = [
            "extend_to_line_bounds"
            "extend_line_above"
            "delete_selection"
          ];
          # open lazygit
          C-g = [
            ":write-all"
            ":new"
            ":insert-output lazygit"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
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
        };
      };

    themes.catppuccin = {
      inherits = "catppuccin_mocha";
      "variable.other.member" = "teal";
    };

    languages = {
      language-server = {
        rust-analyzer.config.check.command = "clippy";
        nginx = {
          command = "nginx-language-server";
          filetypes = [ "nginx" ];
          required-root-patterns = [ "nginx.conf" ];
        };
        eslint = {
          args = [ "--stdio" ];
          command = "vscode-eslint-language-server";
          config.validate = "on";
        };
        typescript-language-server = {
          required-root-patterns = [ "package.json" ];
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
            name = "c";
            file-types = [
              "c"
              "h"
            ];
            formatter.command = "clang-format";
          }
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
              "eslint"
              "deno"
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
              "eslint"
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
