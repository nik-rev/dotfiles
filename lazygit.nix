{ config, ... }:
{
  home-manager.users.${config.user}.programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
      };
      gui = {
        showIcons = true;
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "#cba6f7"
            "bold"
          ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#cba6f7" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
          authorColors = {
            "*" = "#b4befe";
          };
        };
      };
    };
  };
}
