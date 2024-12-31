# download all exercises for an exercism track
# track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
#   jq -r '.exercises[].slug' | \
#   xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"

{ pkgs, lib, ... }:
{
  # zoxide is sourced AFTER extraConfig, which is problematic since my `t` alias does not work
  # So I source it myself and disable the default source to not source the same file twice
  programs.zoxide.enableNushellIntegration = false;
  programs.nushell =
    let
      vivid = lib.getExe pkgs.vivid;
      # we could run this command directly in the configuration file however that command would run everytime nushell starts
      # This way, we run the command just once when we build the system. In the actual configuration file we then have just the string, withoutn needing to spawn a new child process
      colored = builtins.readFile (
        pkgs.runCommand "generate LS_COLORS value" { } "${vivid} generate catppuccin-mocha >$out"
      );
    in
    {
      enable = true;
      extraConfig = ''
        source /home/e/.cache/zoxide/init.nu

        # pass all args to zoxide then list contents of the new directory
        def --env --wrapped t [ ...args: string ] {
          z ...$args
          ^ls --classify --color=always
        }

        # TODO: turn these all into aliases once we have shape_alias
        def --env --wrapped md [ ...args: string ] {
          mkdir ...$args
        }
        def --env --wrapped rd [ ...args: string ] {
          rmdir ...$args
        }
        def --env --wrapped r [ ...args: string ] {
          rm --trash ...$args
        }
        def --env --wrapped n [ ...args: string ] {
          hx ...$args
        }
        def --env no [] {
          hx .
        }
        def --env --wrapped sn [ ...args: string ] {
          sudo -E hx ...$args
        }
        def --env --wrapped e [ ...args: string ] {
          ^ls --classify --color=always ...$args
        }
        def --env --wrapped g [ ...args: string ] {
          git ...$args
        }
        def --env nrs [] {
          sudo nixos-rebuild switch
        }
        def --env --wrapped cat [ ...args: string ] {
          bat --style=plain ...$args
        }
        def --env --wrapped icat [ ...args: string ] {
          wezterm imgcat ...$args
        }
        def --env --wrapped copy [ ...args: string ] {
          xclip -selection clipboard ...$args
        }
        def --env --wrapped icopy [ ...args: string ] {
          xclip -selection clipboard -target image/png ...$args
        }
        def --env --wrapped head [ ...args: string ] {
          bat --style=plain --line-range :10 ...$args
        }
        def --env --wrapped zathura [ ...args: string ] {
          nohup zathura ...$args
        }

        def --env o [] {
          cd ..
          ^ls --classify --color=always
        }

        def --env oo [] {
          cd ../..
          ^ls --classify --color=always
        }

        def --env ooo [] {
          cd ../../..
          ^ls --classify --color=always
        }

        def --env oooo [] {
          cd ../../..
          ^ls --classify --color=always
        }

        def --env ooooo [] {
          cd ../../..
          ^ls --classify --color=always
        }

        $env.PROMPT_COMMAND_RIGHT = {||
          let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
              null => $env.PWD
              '\' => '~'
              $relative_pwd => ([~ $relative_pwd] | path join)
          }

          let path_segment = $"(ansi blue)($dir)(ansi reset)"

          $path_segment | str replace --all (char path_sep) $"(ansi white)(char path_sep) (ansi blue)"
        }

        $env.PROMPT_COMMAND = ""

        # catppuccin compatible colors
        $env.LS_COLORS = r#'${colored}'#

        $env.config.show_banner = false

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

        let scheme = {
          recognized_command: $theme.blue
          unrecognized_command: $theme.text
          constant: $theme.peach
          punctuation: $theme.overlay2
          operator: $theme.sky
          string: $theme.green
          virtual_text: $theme.surface2
        }

        $env.config.color_config = {
          separator: { fg: $theme.surface2 attr: b }
          leading_trailing_space_bg: { attr: n }
          header: { fg: $theme.text attr: b }
          empty: { attr: n }
          bool: $scheme.constant
          int: $scheme.constant
          filesize: {|fsize|
            if $fsize < 1kb {
              $theme.teal
            } else if $fsize < 10kb {
              $theme.green
            } else if $fsize < 100kb {
              $theme.yellow
            } else if $fsize < 10mb {
              $theme.peach
            } else if $fsize < 100mb {
              $theme.maroon
            } else if $fsize < 1gb {
              $theme.red
            } else {
              $theme.mauve
            }
          }
          duration: $scheme.constant
          date: {|| (date now) - $in |
            if $in < 1day {
              $theme.teal
            } else if $in < 1wk {
              $theme.green
            } else if $in < 4wk {
              $theme.yellow
            } else if $in < 12wk {
              $theme.peach
            } else if $in < 24wk {
              $theme.maroon
            } else if $in < 52wk {
              $theme.red
            } else {
              $theme.mauve
            }
          }
          background: $theme.base
          foreground: $theme.text
          range: $scheme.operator
          float: $scheme.constant
          string: $scheme.string
          nothing: $scheme.constant
          binary: $scheme.constant
          cell-path: $scheme.punctuation
          row_index: $theme.subtext1
          record: $theme.text
          list: $theme.text
          hints: $scheme.virtual_text
          search_result: { attr: r }
          shape_closure: $theme.teal
          shape_directory: $theme.blue
          shape_externalarg: $theme.text
          shape_filepath: $theme.blue
          shape_flag: { fg: $theme.maroon attr: i }
          shape_globpattern: $theme.text
          shape_int: $scheme.constant
          shape_internalcall: $scheme.recognized_command
          shape_list: $scheme.punctuation
          shape_matching_brackets: { attr: u }
          shape_nothing: $scheme.constant
          shape_pipe: $scheme.operator
          shape_record: $scheme.punctuation
          shape_string: $scheme.string
          shape_string_interpolation: $theme.flamingo
          shape_raw_string: $scheme.string
          shape_garbage: $theme.red
          shape_keyword: $theme.mauve
          shape_block: $theme.blue
          shape_match_pattern: $theme.green
          shape_operator: $scheme.operator
          shape_table: $scheme.punctuation
          shape_variable: { fg: $theme.peach attr: i }
          shape_bool: $scheme.constant
          shape_signature: $theme.teal
          shape_vardecl: { fg: $theme.peach attr: i }
          shape_external: $scheme.unrecognized_command
          shape_range: $scheme.operator
          shape_redirection: { fg: $theme.text attr: b }
          shape_float: $scheme.constant
          shape_binary: $scheme.constant
          shape_datetime: $scheme.constant
          shape_external_resolved: $scheme.recognized_command
          shape_custom: { fg: "#ff0000" bg: "#ff0000" }
          glob: { fg: "#00ff00" bg: "#00ff00" }
          shape_literal: { fg: "#ffff00" bg: "#ffff00" }
          shape_glob_interpolation: { fg: "#ff00ff" bg: "#ff00ff" }
          block: { fg: "#00ffff" bg: "#00ffff" }
        }
        $env.config.highlight_resolved_externals = true
      '';
      extraLogin = ''
        # auto start i3 when logging in
        if tty == "dev/tty1" {
          startx (which i3 | first | get path)
        };
      '';
    };
}
