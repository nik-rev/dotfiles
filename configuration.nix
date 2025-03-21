{
  pkgs,
  lib,
  pkgs-unstable,
  inputs,
  ...
}:
{
  imports = [
    inputs.hardware-configuration.outPath
    ./vm.nix
  ];

  # Required for sway to start
  hardware.graphics.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment = {
    systemPackages = with pkgs; [
      git
    ];
    sessionVariables = {
      # faster rustc linker times
      RUSTFLAGS = "-C linker=clang -C link-arg=-fuse-ld=${pkgs.mold}/bin/mold";
      # it puts into $HOME/go by default
      GOPATH = "$HOME/.go";
      EDITOR = "hx";

      # required to build some rust packages such as nushell
      # otherwise rust is unable to find these
      LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs-unstable.openssl ];

      # required for openssl
      # see also https://github.com/sfackler/rust-openssl/issues/1663
      PKG_CONFIG_PATH = "${pkgs-unstable.openssl.dev}/lib/pkgconfig";

      # telemetry
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })
      texlivePackages.xcharter
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

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # To set up Sway using Home Manager, first you must enable Polkit in your nix configuration: https://wiki.nixos.org/wiki/Sway
  security.polkit.enable = true;

  users.users.e = {
    initialPassword = "e";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.nushell;
  };

  # required to be able to set zsh as default shell for users
  programs.zsh.enable = true;
  # allows running executables (useful for c++ libraries) https://github.com/nix-community/nix-ld
  programs.nix-ld.enable = true;

  networking = {
    hostName = "nixos";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  services = {
    libinput.enable = true;
    # adds all executables to /usr/bin to be able to run
    # various scripts on NixOS
    envfs.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # required for Vial
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  boot = {
    kernelParams = [
      "intel_pstate=no_hwp"
      "quiet"
    ];
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/luks_root";
  };

  system.stateVersion = "24.11";
}
