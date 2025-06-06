{ pkgs, ... }:
let
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "yazi";
    rev = "5d3a1eecc304524e995fe5b936b8e25f014953e8";
    hash = "sha256-UVcPdQFwgBxR6n3/1zRd9ZEkYADkB5nkuom5SxzPTzk=";
  };
in
{
  programs.yazi.enable = true;
  programs.yazi.package = pkgs.u.yazi;
  programs.yazi.settings = {
    manager.sort_dir_first = true;
  };
  xdg.configFile."yazi/theme.toml".source = "${catppuccin}/themes/mocha/catppuccin-mocha-blue.toml";
}
