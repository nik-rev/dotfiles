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
    ./apps/sway.nix
    ./apps/bat.nix
    ./apps/wezterm.nix
    ./apps/nushell.nix
    ./apps/lazygit.nix
    ./apps/firefox.nix
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
    inputs.ferrishot.packages.${pkgs.system}.default
    inkscape
    racket
    ast-grep
    ### CLI tools
    ripgrep # find text in files
    fd # find files
    skim # find files (fuzzy)
    doggo # dns CLI
    gh # GitHub CLI
    hyperfine # benchmarking tool
    tree # tree view of files
    p7zip # 7z
    pciutils # view connected PCI devices
    onefetch # repository information
    unar # unzip .rar files
    yt-dlp # download tracks from youtube
    imagemagick # monster CLI command for working with images
    ffmpeg # monster CLI command for working with videos

    ### apps
    zathura # document viewer (e.g. PDF)
    termusic # terminal music player
    grim # copy slurp screenshots to clipboard (wayland wl-roots)
    slurp # take screenshots (wayland wl-roots)
    libreoffice # document viewer suite
    vial # keyboard configurator
    gimp # image editor
    scooter # mass search and replace
    mpv # video player
    quickemu # painless virtual machines
    telegram-desktop

    ### system utilities (background)
    brightnessctl # control brightness
    vivid # generates LS_COLORS for directories to look awesome
    acpi # utility to view battery percentage
    wl-clipboard # screenshots on wayland
    pamixer # sound control
    sof-firmware
  ];
  home.stateVersion = "24.11";
}
