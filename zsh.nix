# download all exercises for an exercism track
# track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
#   jq -r '.exercises[].slug' | \
#   xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"

{ pkgs, lib, ... }:
{
  # zoxide is sourced AFTER extraConfig, which is problematic since my `t` alias does not work
  # So I source it myself and disable the default source to not source the same file twice
  programs.zoxide.enableNushellIntegration = false;
  programs.carapace.enable = true;
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
        def --env --wrapped md [ ...args: path ] {
          mkdir ...$args
        }
        def --env --wrapped rd [ ...args: path ] {
          rmdir ...$args
        }
        def --env --wrapped r [ ...args: path ] {
          rm --trash ...$args
        }
        def --env --wrapped n [ ...args: path ] {
          hx ...$args
        }
        def --env no [] {
          hx .
        }
        def --env --wrapped sn [ ...args: path ] {
          sudo -E hx ...$args
        }
        def --env --wrapped e [ ...args: path ] {
          ^ls --classify --color=always ...$args
        }
        def --env --wrapped g [ ...args: string ] {
          git ...$args
        }
        def --env nrs [] {
          sudo nixos-rebuild switch
        }
        def --env --wrapped cat [ ...args: path ] {
          bat --style=plain ...$args
        }
        def --env --wrapped icat [ ...args: path ] {
          wezterm imgcat ...$args
        }
        def --env --wrapped copy [ ...args: string ] {
          xclip -selection clipboard ...$args
        }
        def --env --wrapped icopy [ ...args: string ] {
          xclip -selection clipboard -target image/png ...$args
        }
        def --env --wrapped head [ ...args: path ] {
          bat --style=plain --line-range :10 ...$args
        }
        def --env --wrapped zathura [ ...args: path ] {
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
          variable: { fg: $theme.flamingo attr: i }
          filepath: $theme.yellow
        }

        $env.config.color_config = {
          separator: { fg: $theme.surface2 attr: b }
          leading_trailing_space_bg: { fg: $theme.lavender attr: u }
          header: { fg: $theme.text attr: b }
          row_index: $scheme.virtual_text
          record: $theme.text
          list: $theme.text
          hints: $scheme.virtual_text
          search_result: { fg: $theme.base bg: $theme.yellow }
          shape_closure: $theme.teal
          closure: $theme.teal
          shape_flag: { fg: $theme.maroon attr: i }
          shape_matching_brackets: { attr: u }
          shape_garbage: $theme.red
          shape_keyword: $theme.mauve
          shape_match_pattern: $theme.green
          shape_signature: $theme.teal
          shape_table: $scheme.punctuation
          cell-path: $scheme.punctuation
          shape_list: $scheme.punctuation
          shape_record: $scheme.punctuation
          shape_vardecl: $scheme.variable
          shape_variable: $scheme.variable
          empty: { attr: n }
          filesize: {||
            if $in < 1kb {
              $theme.teal
            } else if $in < 10kb {
              $theme.green
            } else if $in < 100kb {
              $theme.yellow
            } else if $in < 10mb {
              $theme.peach
            } else if $in < 100mb {
              $theme.maroon
            } else if $in < 1gb {
              $theme.red
            } else {
              $theme.mauve
            }
          }
          duration: {||
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
          shape_external: $scheme.unrecognized_command
          shape_internalcall: $scheme.recognized_command
          shape_external_resolved: $scheme.recognized_command
          shape_block: $scheme.recognized_command
          block: $scheme.recognized_command
          shape_custom: $theme.pink
          custom: $theme.pink
          background: $theme.base
          foreground: $theme.text
          cursor: { bg: $theme.rosewater fg: $theme.base }
          shape_range: $scheme.operator
          range: $scheme.operator
          shape_pipe: $scheme.operator
          shape_operator: $scheme.operator
          shape_redirection: $scheme.operator
          glob: $scheme.filepath
          shape_directory: $scheme.filepath
          shape_filepath: $scheme.filepath
          shape_glob_interpolation: $scheme.filepath
          shape_globpattern: $scheme.filepath
          shape_int: $scheme.constant
          int: $scheme.constant
          bool: $scheme.constant
          float: $scheme.constant
          nothing: $scheme.constant
          binary: $scheme.constant
          shape_nothing: $scheme.constant
          shape_bool: $scheme.constant
          shape_float: $scheme.constant
          shape_binary: $scheme.constant
          shape_datetime: $scheme.constant
          shape_literal: $scheme.constant
          string: $scheme.string
          shape_string: $scheme.string
          shape_string_interpolation: $theme.flamingo
          shape_raw_string: $scheme.string
          shape_externalarg: $scheme.string
        }
        $env.config.highlight_resolved_externals = true
        $env.config.explore = {
            status_bar_background: { fg: $theme.text, bg: $theme.mantle },
            command_bar_text: { fg: $theme.text },
            highlight: { fg: $theme.base, bg: $theme.yellow },
            status: {
                error: $theme.red,
                warn: $theme.yellow,
                info: $theme.blue,
            },
            selected_cell: { bg: $theme.blue fg: $theme.base },
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
