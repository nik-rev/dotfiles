# download all exercises for an exercism track
# track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
#   jq -r '.exercises[].slug' | \
#   xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"

{
  pkgs,
  lib,
  pkgs-unstable,
  ...
}:
{
  # zoxide is sourced AFTER extraConfig, which is problematic since my `t` alias does not work. So I source it myself and disable the default source to not source the same file twice
  programs.zoxide.enableNushellIntegration = false;
  # Shell completions for all kinds of commands, all commands are at https://github.com/carapace-sh/carapace-bin
  programs.carapace.enable = true;
  programs.nushell =
    let
      vivid = lib.getExe pkgs.vivid;
      # we could run this command directly in the configuration file however that command would run everytime nushell starts
      # This way, we run the command just once when we build the system. In the actual configuration file we then have just the string, withoutn needing to spawn a new child process
      colored = builtins.readFile (
        pkgs.runCommand "generate LS_COLORS value" { } "${vivid} generate catppuccin-mocha >$out"
      );
      catppuccin-mocha = builtins.readFile (
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/NikitaRevenco/catppuccin-nushell/10a429db05e74787b12766652dc2f5478da43b6f/themes/catppuccin_mocha.nu";
          sha256 = "1pww5kpmcvgp8f8gwb8q8gl0q5jcav069njpa78f3bxlscf48ffn";
        }
      );
      ls-command = "^ls --classify --color=always";
      dir-changes = builtins.concatStringsSep "\n" (
        map (count: ''
          def --env ${lib.concatStrings (lib.replicate count "o")} [] {
            cd ${builtins.concatStringsSep "/" (lib.replicate count "..")}
            ${ls-command}
          }
        '') (lib.range 1 5)
      );
    in
    {
      enable = true;
      package = pkgs-unstable.nushell;
      shellAliases = {
        "md" = "mkdir";
        "rd" = "rmdir";
        "n" = "hx";
        "no" = "hx .";
        "sn" = "sudo -E hx";
        "e" = ls-command;
        "g" = "git";
        "icat" = "wezterm imgcat";
        "nrs" = "sudo nixos-rebuild switch";
        "cat" = "bat --style=plain";
        "copy" = "xclip -selection clipboard";
        "icopy" = "xclip -selection clipboard -target image/png";
        "sway-pad" = "swaymsg gaps left all set 440 ; swaymsg gaps right all set 440";
        "sway-unpad" = "swaymsg gaps left all set 0 ; swaymsg gaps right all set 0";
        # when using `nix develop`, use nushell instead of bash.
        "d" = "nix develop --command nu --execute \"$env.PROMPT_INDICATOR = 'n> '\"";
      };
      extraConfig = ''
        source /home/e/.cache/zoxide/init.nu

        # pass all args to zoxide then list contents of the new directory
        def --env --wrapped t [ ...args: string ] {
          z ...$args
          ^ls --classify --color=always
        }

        # for recording videos in a 16 * 9 resolution on a monitor of a different resolution
        def spad [] {
          swaymsg gaps left all set 440
          swaymsg gaps right all set 440
        }
        def unspad [] {
          swaymsg gaps left all set 0
          swaymsg gaps right all set 0
        }

        def nix-ungit [] {
          cp ../flake.nix .
          git add flake.nix
          nix develop --command nu --execute "$env.PROMPT_INDICATOR = 'n> '"
          rm flake.nix flake.lock
          git add flake.nix
        }

        $env.path = ($env.path | append $"($env.home)/.cache/npm/global/bin")
        $env.path = ($env.path | append $"($env.home)/.cargo/bin")

        $env.PROMPT_COMMAND_RIGHT = {||
          let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
              null => $env.PWD
              '\' => '~'
              $relative_pwd => ([~ $relative_pwd] | path join)
          }

          let path_segment = $"(ansi blue)($dir)(ansi reset)"

          $path_segment | str replace --all (char path_sep) $"(ansi white)(char path_sep) (ansi blue)"
        }

        $env.config.keybindings ++= [
          {
            name: "unfreeze",
            modifier: control,
            keycode: "char_z",
            event: {
              send: executehostcommand,
              cmd: "job unfreeze"
            },
            mode: emacs
          }
        ]

        $env.PROMPT_COMMAND = ""

        $env.config.show_banner = false

        # catppuccin compatible colors
        $env.LS_COLORS = r#'${colored}'#

        ${dir-changes}
        ${catppuccin-mocha}
      '';
      extraLogin = ''
        # auto start i3 when logging in
        if (tty) == "dev/tty1" {
          startx (which i3 | first | get path)
        }
      '';
    };
}
