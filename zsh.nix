# download all exercises for a track
# track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
#   jq -r '.exercises[].slug' | \
#   xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"

{
  # zoxide is sourced AFTER extraConfig, which is problematic since my `t` alias does not work
  # So I source it myself and disable the default source to not source the same file twice
  programs.zoxide.enableNushellIntegration = false;
  programs.nushell = {
    enable = true;
    extraConfig = ''
      source /home/e/.cache/zoxide/init.nu

      # pass all args to zoxide then list contents of the new directory
      def --env --wrapped t [ ...args: string ] {
        z ...$args
        ^ls --classify --color=always
      }

      def . [] {
        cd ..
        #^ls --classify --color=always
      }

      let palette = {
        rosewater: "#f5e0dc"
        flamingo: "#f2cdcd"
        pink: "#f5c2e7"
        mauve: "#cba6f7"
        red: "#f38ba8"
        maroon: "#eba0ac"
        peach: "#fab387"
        yellow: "#f9e2af"
        green: "#a6e3a1"
        teal: "#94e2d5"
        sky: "#89dceb"
        sapphire: "#74c7ec"
        blue: "#89b4fa"
        lavender: "#b4befe"
        text: "#cdd6f4"
        subtext1: "#bac2de"
        subtext0: "#a6adc8"
        overlay2: "#9399b2"
        overlay1: "#7f849c"
        overlay0: "#6c7086"
        surface2: "#585b70"
        surface1: "#45475a"
        surface0: "#313244"
        base: "#1e1e2e"
        mantle: "#181825"
        crust: "#11111b"
      }

      $env.config.buffer_editor = "hx"

      $env.config.color_config = {
        separator: { fg: $theme.surface2 attr: b }
        leading_trailing_space_bg: { attr: n }
        header: $theme.text
        empty: { bg: $theme.green fg: $theme.base }
        bool: $theme.peach
        int: $theme.peach
        filesize: {|fsize|
            if $fsize < 10kb {
                $theme.green
            } else if $fsize < 1mb {
                $theme.yellow
            } else if $fsize < 10mb {
                $theme.peach
            } else if $fsize < 1gb {
                $theme.maroon
            } else if $fsize > 1gb {
                $theme.red
            }
        }
        duration: $theme.text
        date: {|| (date now) - $in |
          if $in < 1wk {
              $theme.green
          } else if $in < 4wk {
              $theme.yellow
          } else if $in < 12wk {
              $theme.peach
          } else if $in < 52wk {
              $theme.maroon
          } else if $in > 52wk {
              $theme.red
          }
        }
        background: $theme.base
        foreground: $theme.text
        range: $theme.text
        float: $theme.text
        string: $theme.text
        nothing: $theme.text
        binary: $theme.text
        cell-path: $theme.text
        row_index: $theme.subtext1
        record: $theme.text
        list: $theme.text
        hints: $theme.surface2
        search_result: { bg: $theme.red fg: $theme.base }
        shape_closure: $theme.teal
        shape_directory: $theme.blue
        shape_externalarg: $theme.text
        shape_filepath: $theme.blue
        shape_flag: $theme.yellow
        shape_globpattern: $theme.text
        shape_int: $theme.peach
        shape_internalcall: $theme.blue
        shape_list: $theme.overlay2
        shape_matching_brackets: { attr: u }
        shape_nothing: $theme.peach
        shape_pipe: $theme.sky
        shape_record: $theme.overlay2
        shape_string: $theme.green
        shape_string_interpolation: $theme.flamingo
        shape_raw_string: $theme.green
        shape_garbage: $theme.red
        shape_keyword: $theme.mauve
        shape_block: $theme.blue
        shape_match_pattern: $theme.green
        shape_operator: $theme.sky
        shape_table: $theme.overlay2
        shape_variable: { fg: $theme.peach attr: i }
        shape_bool: $theme.peach
        shape_signature: $theme.teal
        shape_vardecl: { fg: $theme.peach attr: i }
        shape_external: $theme.blue
        shape_range: $theme.sky
        shape_redirection: { fg: $theme.text attr: b }
        shape_float: $theme.peach
        shape_binary: $theme.peach
        shape_datetime: $theme.peach
        shape_custom: { fg: "#ff0000" bg: "#ff0000" }
        glob: { fg: "#00ff00" bg: "#00ff00" }
        shape_external_resolved: { fg: "#0000ff" bg: "#0000ff" }
        shape_literal: { fg: "#ffff00" bg: "#ffff00" }
        shape_glob_interpolation: { fg: "#ff00ff" bg: "#ff00ff" }
        block: { fg: "#00ffff" bg: "#00ffff" }
      }

      $env.PROMPT_COMMAND_RIGHT = ""

      # catppuccin compatible colors
      $env.LS_COLORS = (vivid generate catppuccin-mocha)

      $env.config.show_banner = false
      $env.config.render_right_prompt_on_last_line = true
      $env.config.history.max_size = 100_000
      $env.config.history.sync_on_enter = true
      $env.config.history.file_format = "sqlite"
      $env.config.history.isolation = false
    '';
    extraLogin = ''
      # auto start i3 when logging in
      if tty == "dev/tty1" {
        startx (which i3 | first | get path)
      };
    '';
    shellAliases = {
      "md" = "mkdir";
      "rd" = "rmdir";
      "r" = "trash";
      "n" = "hx";
      "n." = "hx .";
      "sn" = "sudo -E hx";
      # "." = "cd ..";
      # ".." = "cd ..";
      # "..." = "cd ..";
      # "...." = "cd ..";
      # "....." = "cd ..";
      "e" = "^ls --classify --color=always";
      "g" = "git";
      "nrs" = "sudo nixos-rebuild switch";
      "cat" = "bat --style=plain";
      "icat" = "wezterm imgcat";
      "copy" = "xclip -selection clipboard";
      "icopy" = "xclip -selection clipboard -target image/png";
      "head" = "bat --style=plain --line-range :10";
      "zathura" = "nohup zathura";
    };
  };
}
