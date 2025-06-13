{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./languages.nix
    ./apps/helix.nix
    ./apps/atuin.nix
    ./apps/yazi.nix
    ./apps/gitui.nix
    ./apps/rio.nix
    ./apps/bat.nix
    ./apps/wezterm.nix
    ./apps/nushell.nix
    # --- Not written in Rust
    ./apps/firefox.nix
    ./apps/sway.nix
    ./apps/obs.nix
    ./apps/git.nix
    ./apps/lazygit.nix
    # ---
  ];
  programs = {
    zoxide.enable = true;
    zoxide.package = pkgs.u.zoxide;
  };
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
  };
  home.packages = with pkgs.u; [
    ### CLI tools
    ripgrep # find text in files
    ast-grep # grep AST trees
    fd # find files
    bottom # system monitor
    uutils-coreutils-noprefix # replace the standard GNU tools with Rust coreutils
    inputs.ferrishot.packages.${pkgs.system}.default # screenshot app
    inputs.lumina.packages.${pkgs.system}.default # screenshot app
    hyperfine # benchmarking tool
    onefetch # repository information
    ouch # compression and decompression
    termusic # terminal music player
    serpl # mass search and replace
    vivid # generates LS_COLORS for directories to look awesome
    pastel # color utility tool
    presenterm # markdown terminal slideshow
    batmon # battery TUI
    gitoxide # git rewrite in Rust
    dogedns # dns CLI

    # --- Not written in Rust
    vial # keyboard configurator
    imhex # hex editor
    yt-dlp # download tracks from youtube
    gh # GitHub CLI
    imagemagick # monster CLI command for working with images
    ffmpeg # monster CLI command for working with videos
    gimp # image editor
    slurp # take screenshots (wayland wl-roots)
    wl-clipboard # screenshots on wayland
    pciutils # view connected PCI devices
    grim # copy slurp screenshots to clipboard (wayland wl-roots)
    pamixer # sound control
    sof-firmware
    inkscape # SVG editor
    zathura # document viewer (e.g. PDF)
    mpv # video player
    quickemu # painless virtual machines
    # ---
  ];
  home.stateVersion = "25.05";
}
