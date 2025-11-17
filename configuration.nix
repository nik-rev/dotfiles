# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    cargo-outdated
    cargo-expand
    firefox

    vulkan-tools

    zed-editor

    nodejs
    tombi
    biome

    vulkan-tools
    tailwindcss-language-server
    typescript-language-server
    vscode-json-languageserver
    pnpm
    gopls
    ## CLI tools
    scooter # mass search and replace
    bat # better than `cat`
    mergiraf # better merge conflicts
    just # command runner
    zoxide # better cd
    nushell # shell
    ripgrep # find text in files
    delta # differ
    ast-grep # grep AST trees
    yazi # terminal file manager
    # inputs.wezterm.packages.${pkgs.system}.default # terminal emulator
    kitty
    rio # terminal emulator
    gitui
    fd # find files
    bottom # system monitor
    uutils-coreutils-noprefix # replace the standard GNU tools with Rust coreutils
    hyperfine # benchmarking tool
    atuin # shell history
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
    lazygit # lazygit (git UI)
    vial # keyboard configurator
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
    carapace
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Sound
  services.pipewire = {
    package = pkgs.pipewire;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  }; 

  users.users.e = {
    initialPassword = "e";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.nushell;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      pkgs.nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono NF" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Emoji" ];
      };
    };
  }; 

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.sway.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Be able to resolve dynamic libraries without working, this is useful
  # for e.g. language servers downloaded by Zed to work out of the box
  programs.nix-ld.enable = true;

  networking.networkmanager.enable = true;
}

