{ pkgs, ... }:
let
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "1a8c939e47131f2c4bd07a2daea7773c29e2a774";
    hash = "sha256-hjqmNxIr/KCN9k5ZT7O994BeWdp56NP7aS34+nZ/fQQ=";
  };
in
{
  programs.yazi.enable = true;
  programs.yazi.package = pkgs.u.yazi;
  programs.yazi.settings = {
    mgr.sort_dir_first = true;
  };
  xdg.configFile."yazi/theme.toml".source = "${catppuccin}/themes/mocha/catppuccin-mocha-blue.toml";
}
