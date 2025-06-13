{ pkgs,  ... }:
{
  programs.atuin = {
    enable = true;
    package = pkgs.u.atuin;
    themes = {
      name = "catppuccin-mocha-mauve";
      colors = {
        AlertInfo = "#a6e3a1";
        AlertWarn = "#fab387";
        AlertError = "#f38ba8";
        Annotation = "#cba6f7";
        Base = "#cdd6f4";
        Guidance = "#9399b2";
        Important = "#f38ba8";
        Title = "#cba6f7";
      };
    };
    settings = {
      # do not show help for commands at the top
      show_help = false;
      # do not show tabs for Search / Inspect
      show_tabs = false;
      keymap_mode = "vim-normal";
      style = "full";
    };
    enableNushellIntegration = true;
  };
}
