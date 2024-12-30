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

      $env.config.color_config = {
        # for instance, color of the border of each table
        separator: { fg: $theme.surface2 attr: b }
        leading_trailing_space_bg: { attr: n }
        header: $theme.text
        empty: { bg: $theme.green fg: $theme.base }
        bool: $theme.peach
        int: $theme.peach
        filesize: $theme.peach
        duration: $theme.text
        date: $theme.peach
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
        # in the following code, the closure inside the "list" path `|el|` has this color, as well as the surrounding curly braces
        # def "str append" [tail: string]: [string -> string, list<string> -> list<string>] {
        #     let input = $in
        #     match ($input | describe | str replace --regex '<.*' '\') {
        #         "string" => { $input ++ $tail },
        #         "list" => { $input | each {|el| $el ++ $tail} },
        #         _ => $input
        #     }
        # }
        shape_closure: $theme.teal
        shape_directory: $theme.blue
        shape_externalarg: $theme.text
        shape_filepath: $theme.blue
        shape_flag: $theme.yellow
        # for instance, inputs to a command like `ls`. So `ls file1 *.txt`, both args are this
        shape_globpattern: $theme.text
        # invalid command, for example if `l` is not a command then it will have this color
        # for unknown reasons, this isn't reserved for actual integers
        shape_int: $theme.blue
        # command that is a binary, e.g. `ls`
        shape_internalcall: $theme.blue
        # syntax for lists, for example in [1, 2, 3, 4, 5] the square brackets and the comma use this syntax
        shape_list: $theme.overlay2
        # whatever is matching, for example we could be autocompleting on a filename
        # the part of the filename which matches what we have is going to have this style
        shape_matching_brackets: { attr: u }
        # `null` and `nothing`
        shape_nothing: $theme.peach
        # the `|` symbol to pipe between commands
        shape_pipe: $theme.sky
        # for example in { "apples": 543, "bananas": 411, "oranges": 0 }, the commas, curly braces and colons use this highlight
        shape_record: $theme.overlay2
        # for example: 'hello world'
        shape_string: $theme.green
        # symbols for the interpolated string, for example in $"greetings, ($name)" the following characters use this: $, first " and the last "
        shape_string_interpolation: $theme.flamingo
        # for example: r#'hello world'
        shape_raw_string: $theme.green
        # invalid syntax
        shape_garbage: $theme.red
        # In the following code, `else` uses this highlight
        # [black red yellow green purple blue] | each {|c|
        #   if ($c == "black") {
        #    "classy"
        #   } else if ($c in ["red", "green", "blue"]) {
        #     "fundamental"
        #   } else if ($c in ['yellow', "purple"]) {
        #     "vibrant"
        #   } else {
        #     "innovative"
        #   }
        # }
        shape_keyword: $theme.mauve
        # In the following code, the indentation uses this highlight
        # as well as the first `if`, the parentheses around the condition, and the curly braces inside of each of the conditions
        # [black red yellow green purple blue] | each {|c|
        #   if ($c == "black") {
        #    "classy"
        #   } else if ($c in ["red", "green", "blue"]) {
        #     "fundamental"
        #   } else if ($c in ['yellow', "purple"]) {
        #     "vibrant"
        #   } else {
        #     "innovative"
        #   }
        # }
        shape_block: $theme.blue
        # in the following code, all the possibilities are match items
        # [black red yellow green purple blue indigo] | each {|c|
        #   match $c {
        #     "black" => "classy"
        #     "red" | "green" | "blue" => "fundamental"
        #     "yellow" | "purple" => "vibrant"
        #     _ => "innovative"
        #   }
        # }
        shape_match_pattern: $theme.green
        # In the following code, `in` and `==` use this highlight
        # [black red yellow green purple blue] | each {|c|
        #   if ($c == "black") {
        #    "classy"
        #   } else if ($c in ["red", "green", "blue"]) {
        #     "fundamental"
        #   } else if ($c in ['yellow', "purple"]) {
        #     "vibrant"
        #   } else {
        #     "innovative"
        #   }
        # }
        shape_operator: $theme.sky
        # simply any sort of command even if its invalid. We can't color it a color like red since aliases don't get a special color
        shape_table: $theme.lavender
        # a variable like $c for example
        shape_variable: { fg: $theme.peach attr: i }
        # true and false
        shape_bool: $theme.peach
        # in the following code, highlight is applied to [tail: string]: [string -> string, list<string> -> list<string>]
        # def "str append" [tail: string]: [string -> string, list<string> -> list<string>] {
        #     let input = $in
        #     match ($input | describe | str replace --regex '<.*' '\') {
        #         "string" => { $input ++ $tail },
        #         "list" => { $input | each {|el| $el ++ $tail} },
        #         _ => $input
        #     }
        # }
        shape_signature: $theme.teal
        # in the following snippet, `fish_completer` declaration gets this highlight
        # let fish_completer = {|spans|
        #     fish --command $'complete "--do-complete=($spans | str join " ")"'
        #     | from tsv --flexible --noheaders --no-infer
        #     | rename value description
        # }
        shape_vardecl: { fg: $theme.peach attr: i }
        # commands which are not a part of nushell, or maybe they're not command at all
        # e.g. `l` is not a command, but it gets this color
        shape_external: $theme.blue
        # a range like 1..5
        shape_range: $theme.sky
        # in the following snippet, `out>` and `err>` are redirection
        # cat unknown.txt out> out.log err> err.log
        shape_redirection: { fg: $theme.text attr: b }
        # e.g. 1.41
        shape_float: $theme.peach
        # for example
        # 0x[ffffff]
        # 0o[12374]
        # 0b[1010110101001]
        shape_binary: $theme.peach
        # for example
        # 2022-02-02
        # 2022-02-02T14:30:00+05:00
        shape_datetime: $theme.peach
        
        # An opaque data type that is only used internally in Nushell by built-in commands or plugins.
        # Below cannot appear in the terminal
        # shape_custom: "#ff0000"
        # glob: "#ff0000"
        # shape_external_resolved: "#ff0000"
        # shape_literal: "#ff0000"
        # shape_glob_interpolation: "#ff0000"
        # block: "#ff0000"
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
