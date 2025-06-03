{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./languages.nix
    ./apps/git.nix
    ./apps/helix.nix
    ./apps/yazi.nix
    ./apps/gitui.nix
    ./apps/obs.nix
    ./apps/rio.nix
    ./apps/bat.nix
    ./apps/wezterm.nix
    ./apps/nushell.nix
    # --- Not written in Rust
    ./apps/firefox.nix
    ./apps/sway.nix
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
    uutils-coreutils-noprefix # replace the standard GNU tools with Rust coreutils
    inputs.ferrishot.packages.${pkgs.system}.default # screenshot app
    hyperfine # benchmarking tool
    ripunzip # unzip files
    onefetch # repository information
    termusic # terminal music player
    serpl # mass search and replace
    vivid # generates LS_COLORS for directories to look awesome

    # --- Not written in Rust
    brightnessctl # control brightness
    acpi # utility to view battery percentage
    vial # keyboard configurator
    doggo # dns CLI
    unar # unzip .rar files
    yt-dlp # download tracks from youtube
    gh # GitHub CLI
    imagemagick # monster CLI command for working with images
    ffmpeg # monster CLI command for working with videos
    gimp # image editor
    slurp # take screenshots (wayland wl-roots)
    wl-clipboard # screenshots on wayland
    tree # tree view of files
    pciutils # view connected PCI devices
    libreoffice # document viewer suite
    grim # copy slurp screenshots to clipboard (wayland wl-roots)
    pamixer # sound control
    sof-firmware
    inkscape # SVG editor
    zathura # document viewer (e.g. PDF)
    mpv # video player
    quickemu # painless virtual machines
    telegram-desktop
    # ---
  ];
  home.stateVersion = "24.11";
}
