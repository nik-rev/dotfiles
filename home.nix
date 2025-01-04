{
  pkgs,
  config,
  pkgs-unstable,
  pkgs-old,
  inputs,
  ...
}:
{
  imports = [
    ./helix.nix
    ./bat.nix
    ./firefox.nix
    ./git.nix
    ./lazygit.nix
    ./zsh.nix
    ./i3.nix
    ./languages.nix
  ];

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  xdg.userDirs.download = "${config.home.homeDirectory}/t";
  xsession.windowManager.i3.enable = true;
  services.flameshot.enable = true;
  programs = {
    yazi.enable = true;
    zoxide.enable = true;
    wezterm = {
      enable = true;
      # currently, rendering is broken in the new wezterm versions https://github.com/NixOS/nixpkgs/issues/336069
      package = inputs.wezterm.packages.${pkgs.system}.default;
    };
    ripgrep.enable = true;
    fzf.enable = true;
    fd.enable = true;
    go.enable = true;
    go.goBin = "go/bin";
  };
  home = {
    sessionPath = [
      "$HOME/.cache/npm/global/bin"
      "$HOME/.cargo/bin"
    ];
    pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    packages =
      with pkgs;
      [
        sof-firmware
        ripgrep
        libreoffice
        xclip
        # google-chrome
        p7zip
        exercism
        zathura
        inputs.patchy.packages.${pkgs.system}.default
        brightnessctl
        gimp
        catppuccin-whiskers
        just
        # generates LS_COLORS
        vivid
        onefetch
        imagemagick
        # sound control
        pamixer
        # otherwise playwright will not work
        # chromium
      ]
      ++ (with pkgs-unstable; [
        # for recordings
        gnome-terminal
        playwright-test
        doggo
        jq
        # playwright-driver
        dconf
        asciinema
        # interactive search and replace
        scooter
        # benchmarking tool
        hyperfine
      ]);
    stateVersion = "24.11";
  };
}
