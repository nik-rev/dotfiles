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

      let theme = {
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

      # let-env PROMPT_COMMAND_RIGHT = {|| pwd | str replace $env.HOME ~}
      $env.PROMPT_COMMAND_RIGHT = ""

      $env.config.show_banner = false
      $env.config.render_right_prompt_on_last_line = true
      $env.config.history.max_size = 100_000
      $env.config.history.sync_on_enter = true
      $env.config.history.file_format = "sqlite"
      $env.config.history.isolation = false

      # theme

      #$env.config.color_config.hints = $theme.overlay2
      #$env.config.color_config.empty = $theme.sky
      #$env.config.color_config.shape_garbage = $theme.red
      #$env.config.color_config.shape_bool = $theme.peach
      #$env.config.color_config.shape_int = $theme.peach
      #$env.config.color_config.shape_float = $theme.peach
      #$env.config.color_config.shape_range = { fg: $theme.yellow attr: b}
      #$env.config.color_config.shape_internalcall = { fg: $theme.blue attr: b}
      #$env.config.color_config.shape_external = { fg: $theme.blue attr: b}
      #$env.config.color_config.shape_externalarg = $theme.text 
      #$env.config.color_config.shape_literal = $theme.peach
      #$env.config.color_config.shape_operator = $theme.sky
      #$env.config.color_config.shape_signature = { fg: $theme.green attr: b}
      #$env.config.color_config.shape_string = $theme.text
      #$env.config.color_config.shape_filepath = $theme.yellow
      #$env.config.color_config.shape_globpattern = { fg: $theme.green attr: b}
      #$env.config.color_config.shape_variable = $theme.text
      #$env.config.color_config.shape_flag = { fg: $theme.yellow attr: b}
      #$env.config.color_config.shape_custom = {attr: b}

      $env.config.color_config = {
        separator: $theme.surface1
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: light_cyan
        int: white
        filesize: cyan
        duration: white
        date: purple
        range: white
        float: white
        string: white
        nothing: white
        binary: white
        cell-path: white
        row_index: green_bold
        record: white
        list: white
        closure: green_bold
        glob:cyan_bold
        block: white
        hints: $theme.surface2
        search_result: { bg: red fg: white }
        shape_binary: purple_bold
        shape_block: $theme.green
        shape_bool: light_cyan
        shape_closure: green_bold
        shape_custom: green
        shape_datetime: cyan_bold
        shape_directory: $theme.blue
        shape_external: cyan
        shape_externalarg: green_bold
        shape_external_resolved: light_yellow_bold
        shape_filepath: cyan
        shape_flag: blue_bold
        shape_float: purple_bold
        shape_glob_interpolation: cyan_bold
        shape_globpattern: cyan_bold
        shape_int: purple_bold
        shape_internalcall: cyan_bold
        shape_keyword: cyan_bold
        shape_list: cyan_bold
        shape_literal: blue
        shape_match_pattern: green
        shape_matching_brackets: { attr: u }
        shape_nothing: light_cyan
        shape_operator: yellow
        shape_pipe: purple_bold
        shape_range: yellow_bold
        shape_record: cyan_bold
        shape_redirection: purple_bold
        shape_signature: green_bold
        shape_string: green
        shape_string_interpolation: cyan_bold
        shape_table: blue_bold
        shape_variable: purple
        shape_vardecl: purple
        shape_raw_string: light_purple
        shape_garbage: $theme.red
      }
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
