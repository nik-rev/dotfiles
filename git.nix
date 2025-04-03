{ pkgs-unstable, ... }:
{
  programs.gitui = {
    enable = true;
    package = pkgs-unstable.gitui;
    theme = ''
      (
          selected_tab: Some("Reset"),
          command_fg: Some("#cdd6f4"),
          selection_bg: Some("#585b70"),
          selection_fg: Some("#cdd6f4"),
          cmdbar_bg: Some("#181825"),
          cmdbar_extra_lines_bg: Some("#181825"),
          disabled_fg: Some("#7f849c"),
          diff_line_add: Some("#a6e3a1"),
          diff_line_delete: Some("#f38ba8"),
          diff_file_added: Some("#a6e3a1"),
          diff_file_removed: Some("#eba0ac"),
          diff_file_moved: Some("#cba6f7"),
          diff_file_modified: Some("#fab387"),
          commit_hash: Some("#b4befe"),
          commit_time: Some("#bac2de"),
          commit_author: Some("#74c7ec"),
          danger_fg: Some("#f38ba8"),
          push_gauge_bg: Some("#89b4fa"),
          push_gauge_fg: Some("#1e1e2e"),
          tag_fg: Some("#f5e0dc"),
          branch_fg: Some("#94e2d5")
      )
    '';
  };
  programs.git = {
    enable = true;
    userName = "Nik Revenco";
    userEmail = "154856872+NikitaRevenco@users.noreply.github.com";
    aliases = {
      # downloads commits and trees while fetching blobs on-demand
      # this is better than a shallow git clone --depth=1 for many reasons
      "partial-clone" = "clone --filter=blob:none";
    };
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      safe.directory = "*";
      rerere.enabled = true;
      column.ui = "auto";
      branch.sort = "committerdate";
      diff.tool = "delta";
    };
    delta = {
      enable = true;
      options = {
        features = "catppuccin-mocha";
        line-numbers = false;
        "catppuccin-mocha" = {
          blame-palette = "#1e1e2e #181825 #11111b #313244 #45475a";
          commit-decoration-style = "box ul";
          dark = true;
          file-decoration-style = "#cdd6f4";
          file-style = "#cdd6f4";
          hunk-header-decoration-style = "box ul";
          hunk-header-file-style = "bold";
          hunk-header-line-number-style = "bold #a6adc8";
          hunk-header-style = "file line-number syntax";
          line-numbers = true;
          line-numbers-left-style = "#6c7086";
          line-numbers-minus-style = "bold #f38ba8";
          line-numbers-plus-style = "bold #a6e3a1";
          line-numbers-right-style = "#6c7086";
          line-numbers-zero-style = "#6c7086";
          minus-emph-style = "bold syntax #53394c";
          minus-style = "syntax #34293a";
          plus-emph-style = "bold syntax #404f4a";
          plus-style = "syntax #2c3239";
          map-styles = ''
            bold purple => syntax "#494060",
                 bold blue => syntax "#384361",
                 bold cyan => syntax "#384d5d",
                 bold yellow => syntax "#544f4e"
          '';
          # Should match the name of the bat theme
          syntax-theme = "catppuccin";
        };
      };
    };
  };
}
