{
  pkgs,
  lib,
  inputs,
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
          space.x = ":write-quit-all";
          space.X = ":write-quit-all!";
          space.C-d = "@<space>D%severity ERROR";
          tab = "collapse_selection";
          x = "select_line_below";
          X = "select_line_above";
          S-left = "jump_backward";
          S-right = "jump_forward";
          ret = ":write";
          left = "@[";
          right = "@]";
          up = "select_textobject_inner";
          down = "select_textobject_around";
          space.e = [
            ":sh rm -f /tmp/unique-file-u41ae14"
            ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-u41ae14"
            ":insert-output echo \"\x1b[?1049h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file-u41ae14}"
            ":redraw"
          ];
          space.E = [
            ":sh rm -f /tmp/unique-file-h21a434"
            ":insert-output yazi '%{workspace_directory}' --chooser-file=/tmp/unique-file-h21a434"
            ":insert-output echo \"\x1b[?1049h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file-h21a434}"
            ":redraw"
          ];
          C-g = [
            ":write-all"
            ":insert-output lazygit >/dev/tty"
            ":redraw"
            ":reload-all"
          ];
          C-e = [
            ":write-all"
            ":insert-output scooter >/dev/tty"
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
          # rebindings because default keymap is awkward with my custom keyboard layout
          # DEFAULT: A-C
          A-c = "copy_selection_on_prev_line";
          # DEFAULT: A-J
          C-j = "join_selections_space";
          # DEFAULT: A-K
          C-k = "remove_selections";
          # DEFAULT: A-I
          C-c = "select_all_children";
          # DEFAULT: A-n
          A-right = "select_next_sibling";
          # DEFAULT: A-U
          C-S-u = "later";
        };
      in
      {
        theme = "catppuccin";
        editor = {
          # uses system clipboard
          default-yank-register = "+";
          idle-timeout = 5;
          completion-timeout = 5;
          smart-tab.enable = false;
          auto-info = false;
          soft-wrap.enable = true;
          line-number = "relative";
          inline-diagnostics.cursor-line = "hint";
          cursorline = true;
          lsp.auto-signature-help = false;
          statusline = {
            left = [ ];
            center = [ ];
            right = [
              "spinner"
              "file-name"
              "diagnostics"
            ];
            # merge-with-commandline = true;
          };
          indent-guides = {
            character = "╎";
            skip-levels = 1;
            render = true;
          };
        };
        keys = {
          select = keybindings // {
            backspace = "extend_to_word";
          };
          normal = keybindings // {
            # newline without comment
            backspace = "goto_word";
          };
          insert.A-ret = [
            "insert_newline"
            "delete_word_backward"
          ];
        };
      };

    themes.catppuccin = {
      inherits = "catppuccin_mocha";
      "variable.other.member" = "teal";
      # this is actually the default but Helix master hasn't synced the catppuccin changes yet
      "function.macro" = "rosewater";
      rainbow = [
        "red"
        "peach"
        "yellow"
        "green"
        "sapphire"
        "lavender"
      ];
    };

    languages = {
      language-server = {
        steel-language-server = {
          command = "steel-language-server";
          args = [ ];
        };
        rust-analyzer.config = {
          check.command = "clippy";
          # makes it work when in an integration_test
          # cargo.features = [ "integration" ];
          # checkOnSave.allTargets = true;
          # rustfmt.extraArgs = [ "+nightly" ];
          # config.rustfmt.extraArgs = [ "+nightly" ];
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
          command = lib.getExe pkgs.u.tailwindcss-language-server;
          args = [ "--stdio" ];
        };
        ruff = {
          command = lib.getExe pkgs.u.ruff;
        };
        gopls.config.gofumpt = true;
        astro-ls = {
          command = lib.getExe pkgs.u.nodePackages."@astrojs/language-server";
          args = [ "--stdio" ];
          config = {
            typescript = {
              tsdk = "${pkgs.u.typescript}/lib/node_modules/typescript/lib";
              environment = "node";
            };
          };
        };
        # https://github.com/tekumara/typos-lsp/blob/main/docs/helix-config.md
        typos-lsp = {
          command = lib.getExe pkgs.u.typos-lsp;
          environment.RUST_LOG = "error";
          config.diagnosticSeverity = "Warning";
        };
      };

      language =
        let
          prettierd = lang: {
            command = lib.getExe pkgs.u.prettierd;
            args = [ lang ];
          };
          prettier = plugin: parser: {
            command = lib.getExe pkgs.u.nodePackages.prettier;
            args = [
              "--plugin"
              plugin
              "--parser"
              parser
            ];
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
            formatter = prettier "prettier-plugin-astro" "astro";
          }
          {
            name = "scheme";
            language-servers = [ "steel-language-server" ];
            formatter = {
              command = "raco";
              args = [
                "fmt"
                "-i"
              ];
            };
          }
          {
            name = "nix";
            auto-pairs = {
              "=" = ";";
              # unchanged:
              "(" = ")";
              "{" = "}";
              "[" = "]";
              "'" = "'";
              "\"" = "\"";
              "`" = "`";
            };
          }
          {
            name = "svelte";
            language-servers = [
              "svelteserver"
              "tailwindcss"
            ];
            formatter = prettier "prettier-plugin-svelte" "svelte";
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
            formatter = prettierd ".ts";
            language-servers = [
              "typescript-language-server"
              "eslint"
              "deno"
            ];
          }
          {
            name = "yaml";
            formatter = prettierd ".yaml";
          }
          {
            name = "markdown";
            formatter = prettierd ".md";
            language-servers = [ "typos-lsp" ];
            comment-tokens = [
              "-"
              "+"
              "*"
              "1."
              ">"
              "- [ ]"
            ];
          }
          {
            name = "scss";
            formatter = prettierd ".scss";
          }
          {
            name = "css";
            formatter = prettierd ".css";
          }
          {
            name = "tsx";
            formatter = prettierd ".tsx";
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
            formatter = prettierd ".jsx";
          }
          {
            name = "json";
            formatter = prettierd ".json";
          }
          {
            name = "toml";
            formatter.command = lib.getExe pkgs.u.taplo;
            formatter.args = [
              "format"
              "-"
            ];
          }
          {
            name = "html";
            formatter = prettierd ".html";
          }
          {
            name = "c-sharp";
            formatter.command = lib.getExe pkgs.u.csharpier;
          }
          {
            name = "javascript";
            formatter = prettierd ".js";
          }
          {
            name = "nix";
            formatter.command = lib.getExe pkgs.u.nixfmt-rfc-style;
          }
          {
            name = "lua";
            formatter.command = lib.getExe pkgs.u.stylua;
            formatter.args = [ "-" ];
          }
          {
            name = "bash";
            formatter.command = lib.getExe pkgs.u.shfmt;
          }
          {
            name = "haskell";
            formatter.command = lib.getExe pkgs.u.ormolu;
            formatter.args = [
              "--stdin-input-file"
              "."
            ];
          }
        ]);
    };
  };
}
