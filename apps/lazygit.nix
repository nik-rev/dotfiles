{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    package = pkgs.u.lazygit;
    settings = {
      git.paging = {
        colorArg = "always";
        pager = "delta --dark --paging=never;";
      };
      update.method = "never";
      gui = {
        showIcons = true;
        nerdFontsVersion = "3";
        showBottomLine = false;
        animateExplosion = false;
        showListFooter = false;
        showCommandLog = false;
        quitOnTopLevelReturn = true;
        showPanelJumps = false;
        commitHashLength = 0;
        statusPanelView = "allBranchesLog";
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
