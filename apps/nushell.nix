# download all exercises for an exercism track
# track=$TRACK_NAME; curl "https://exercism.org/api/v2/tracks/$track/exercises" | \     ~/exercism/rust
#   jq -r '.exercises[].slug' | \
#   xargs -I {} -n1 sh -c "exercism download --track=$track --exercise {} || true"

{
  pkgs,
  lib,
  ...
}:
{
  # zoxide is sourced AFTER extraConfig, which is problematic since my `t` alias does not work. So I source it myself and disable the default source to not source the same file twice
  programs.zoxide.enableNushellIntegration = false;
  # Shell completions for all kinds of commands, all commands are at https://github.com/carapace-sh/carapace-bin
  programs.carapace.enable = true;
  programs.nushell =
    let
      zoxide = lib.getExe pkgs.u.zoxide;
      # adds lots of cool colors to different file types
      vivid = lib.getExe pkgs.u.vivid;
      # we could run this command directly in the configuration file however that command would run everytime nushell starts
      # This way, we run the command just once when we build the system. In the actual configuration file we then have just the string, withoutn needing to spawn a new child process
      colored = builtins.readFile (
        pkgs.runCommand "generate LS_COLORS value" { } "${vivid} generate catppuccin-mocha >$out"
      );
      zoxideIntegration = builtins.readFile (
        pkgs.runCommand "generate LS_COLORS value" { } "${zoxide} init nushell >$out"
      );
      catppuccin-mocha = builtins.readFile (
        builtins.fetchurl {
          url = "https://raw.githubusercontent.com/NikitaRevenco/catppuccin-nushell/10a429db05e74787b12766652dc2f5478da43b6f/themes/catppuccin_mocha.nu";
          sha256 = "1pww5kpmcvgp8f8gwb8q8gl0q5jcav069njpa78f3bxlscf48ffn";
        }
      );
      ls-command = "^ls --classify -rt --color=always";
      # . => go to parent directory;
      # .. => go to parent's parent directory;
      # ..., ...., ..... similarly go 1 level up
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
      package = pkgs.u.nushell;
      shellAliases = {
        "e" = ls-command;
        "icat" = "wezterm imgcat";
        "nrs" = "sudo nixos-rebuild switch";
        "cat" = "bat --style=plain";
        "copy" = "xclip -selection clipboard";
        "icopy" = "xclip -selection clipboard -target image/png";
        "c" = "cargo";
        "g" = "git";
        "lg" = "lazygit";
        "rz" = "ripunzip";
        "n" = "hx";
        "no" = "hx .";
        "sn" = "sudo -E hx";
      };
      extraConfig = # nu
        ''
          ${zoxideIntegration}

          # pass all args to zoxide then list contents of the new directory
          def --env --wrapped t [ ...args: string ] {
            z ...$args
            ^ls --classify --color=always
          }

          # `nix develop` with nushell
          def --wrapped d [ ...args: string ] {
            nix develop ...$args --command nu --execute "$env.PROMPT_INDICATOR = 'n> '"
          }

          # `nix-shell` with nushell
          def --wrapped ns [ ...args: string ] {
            nix-shell ...$args --run `nu --execute "\$env.PROMPT_INDICATOR = 'ns> '"`
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

          # ctrl-z to toggle foreground and background
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

          # catppuccin compatible colors for ls
          $env.LS_COLORS = r#'${colored}'#

          ${dir-changes}
          ${catppuccin-mocha}
        '';
    };
}
