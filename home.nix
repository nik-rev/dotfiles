{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./firefox.nix
    ./sway.nix
  ];
  programs = {
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        droidcam-obs
      ];
    };
    go = {
      enable = true;
      goBin = "go/bin";
    };
  };
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    gtk.enable = true;
    x11.enable = true;
  };
  home.packages = with pkgs.u; [
    ### CLI tools
    pkgs.u.scooter # mass search and replace
    pkgs.u.bat # better than `cat`
    pkgs.u.mergiraf # better merge conflicts
    pkgs.u.zoxide # better cd
    pkgs.u.nushell # shell
    ripgrep # find text in files
    inputs.helix.packages.${pkgs.system}.helix # editor
    delta # differ
    ast-grep # grep AST trees
    pkgs.u.yazi # terminal file manager
    inputs.wezterm.packages.${pkgs.system}.default # terminal emulator
    pkgs.u.rio # terminal emulator
    pkgs.u.gitui
    fd # find files
    bottom # system monitor
    uutils-coreutils-noprefix # replace the standard GNU tools with Rust coreutils
    inputs.ferrishot.packages.${pkgs.system}.default # screenshot app
    inputs.lumina.packages.${pkgs.system}.default # screenshot app
    hyperfine # benchmarking tool
    pkgs.u.atuin # shell history
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
    rqbit # CLI torrent client

    # --- Not written in Rust
    pkgs.u.lazygit # lazygit (git UI)
    vial # keyboard configurator
    imhex # hex editor
    yt-dlp # download tracks from youtube
    git
    gh # GitHub CLI
    imagemagick # monster CLI command for working with images
    ffmpeg # monster CLI command for working with videos
    #gimp # image editor
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

    # --- Language or tooling specific
    clang
    gnumake
    typos-lsp

    ## markdown
    typos # spell checker
    typos-lsp # spell checker markdown LSP

    ## typst
    typst # compiler
    typstyle # formatter
    tinymist # language server

    ## rust
    rustup # install everything Rust
    zola # static site generator

    ## nix
    nil # language server
    nixfmt-rfc-style # formatter

    # to be able to view built static websites on localhost
    live-server
    racket
    pkgs.u.carapace
    # ---
  ];
  home.stateVersion = "25.05";
}
