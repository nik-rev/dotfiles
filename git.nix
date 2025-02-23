{
  programs.git = {
    enable = true;
    userName = "Nikita Revenco";
    userEmail = "154856872+NikitaRevenco@users.noreply.github.com";
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
      safe.directory = "*";
      rerere.enabled = true;
      column.ui = "auto";
      branch.sort = "committerdate";
    };
    aliases = {
      # downloads commits and trees while fetching blobs on-demand
      # this is better than a shallow git clone --depth=1 for many reasons
      "partial-clone" = "clone --filter=blob:none";
    };
  };
}
