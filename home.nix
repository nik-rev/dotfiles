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
    mergiraf.enable = true;
    mergiraf.package = pkgs.u.mergiraf;
  };
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
  };
  home.packages = with pkgs.u; [
    ### CLI tools
    # currently, font rendering is broken in the new wezterm versions https://github.com/NixOS/nixpkgs/issues/336069
    # inputs.wezterm.packages.${pkgs.system}.default # terminal emulator
    # bat # better than `cat`
    # pkgs.u.yazi # CLI file manager
    # pkgs.u.nushell # shell
    # pkgs.u.atuin # magical shell history
    # pkgs.u.rio # terminal emulator
    ripgrep # find text in files
    # inputs.helix.packages.${pkgs.system}.helix # editor
    # pkgs.u.gitui # git UI (like lazygit but in Rust)
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
    websocat # websocket CLI
    rqbit

    # --- Not written in Rust
    pkgs.u.lazygit # lazygit (git UI)
    vial # keyboard configurator
    imhex # hex editor
    yt-dlp # download tracks from youtube
    gh # GitHub CLI
    imagemagick # monster CLI command for working with images
    ffmpeg # monster CLI command for working with videos
    gimp # image editor
    git # vcs
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
