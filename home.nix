{
  pkgs,
  pkgs-unstable,
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
    zoxide.package = pkgs-unstable.zoxide;
    ripgrep.enable = true;
    fzf.enable = true;
    fd.enable = true;
    go.enable = true;
    go.goBin = "go/bin";
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        droidcam-obs
      ];
    };
  };
  home.packages = with pkgs-unstable; [
    sof-firmware
    p7zip
    imagemagick
    aider-chat
    act # local github CI runner
    just # command runner
    brightnessctl # control brightness
    quickemu # painless virtual machines
    zathura # document viewer (e.g. PDF)
    libreoffice # document viewer suite
    onefetch # repository information
    pamixer # sound control
    gimp # image editor
    vivid # generates LS_COLORS
    wl-clipboard
    doggo # dns CLI
    dconf
    gh # GitHub CLI
    scooter # mass search and replace
    hyperfine # benchmarking tool
    slurp # take screenshots (wayland wl-roots)
    grim # copy slurp screenshots to clipboard (wayland wl-roots)
    tree # tree view of files
    vial # keyboard configurator
    mpv # video player
    typos # spell checker
    typos-lsp # spell checker markdown LSP
    acpi # utility to view battery percentage
    leetgo # leetcode using Helix editor
    unar # unzip .rar files
    pciutils # view connected PCI devices
    telegram-desktop
  ];
  home.stateVersion = "24.11";
}
