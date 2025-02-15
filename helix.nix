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
          ret = ":write";
          left = "@[";
          right = "@]";
          up = "select_textobject_inner";
          down = "select_textobject_around";
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
          # rebindings because default keymap is a bit awkward with my custom layout
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
            merge-with-commandline = true;
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
        # newline without comment
        keys.insert.A-ret = [
          "insert_newline"
          "delete_word_backward"
        ];
      };

    themes.catppuccin = {
      inherits = "catppuccin_mocha";
      # custom improvements
      "variable.other.member" = "teal";
      "function.macro" = "rosewater";

      "ui.selection" = {
        bg = "surface0";
      };

      # these changes are synced from the main catppuccin
      # repository. Once the catppuccin theme is updated for Helix
      # upstream, remove this code
      "ui.cursor.primary.normal" = {
        fg = "base";
        bg = "rosewater";
      };
      "ui.cursor.primary.select" = {
        fg = "base";
        bg = "lavender";
      };
      "ui.cursor.normal" = {
        fg = "base";
        bg = "#b5a6a8";
      };
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
      "markup.heading.1" = "red";
      "markup.heading.2" = "peach";
      "markup.heading.3" = "yellow";
      "markup.heading.4" = "green";
      "markup.heading.5" = "sapphire";
      "markup.heading.6" = "lavender";
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
        rust-analyzer.config = {
          check.command = "clippy";
          # makes it work when in an integration_test
          # cargo.features = [ "integration_test" ];
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

      language =
        let
          prettierd = lang: {
            command = lib.getExe pkgs-unstable.prettierd;
            args = [ lang ];
          };
          prettier = plugin: parser: {
            command = lib.getExe pkgs-unstable.nodePackages.prettier;
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
            formatter.command = lib.getExe pkgs-unstable.taplo;
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
            formatter.command = lib.getExe pkgs-unstable.csharpier;
          }
          {
            name = "javascript";
            formatter = prettierd ".js";
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
