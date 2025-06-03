{
  pkgs,
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
          m."\"" = "@f\";vmmdi\"";
          m."'" = "@f';vmmdi'";
          m."[" = "@f];vmmdi[";
          m."(" = "@f);vmmdi(";
          m."<" = "@f<gt>;vmmdi<lt><gt><left>";
          m."{" = "@f};vmmdi{";
          space.x = ":write-quit-all";
          space.X = ":write-quit-all!";
          space.C-d = "@<space>D%severity ERROR ";
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
    };

    languages = {
      language-server = {
        rust-analyzer.config = {
          check.command = "clippy";
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
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
      ];
    };
  };
}
