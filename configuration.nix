{
  pkgs,
  inputs,
  ...
}:
let
  user_id = 1000;
  username = "e";
in
{
  imports = [
    inputs.hardware-configuration.outPath
    ./vm.nix
    ./nvidia.nix
  ];

  # --- Get rid of the "Bad credentials" error in GitUI

  # environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/${builtins.toString user_id}/ssh-agent";
  # programs.ssh.startAgent = true;
  
  # systemd.user.services.ssh-add-key = {
  #   wantedBy = [ "default.target" ];
  #   after = [ "ssh-agent.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStartPre = "${pkgs.coreutils-full}/bin/sleep 1";
  #     ExecStart = [
  #       "${pkgs.openssh}/bin/ssh-add ${config.users.users.${username}.home}/.ssh/id_ed25519"
  #     ];
  #     Restart = "on-failure";
  #     RestartSec = 1;
  #   };
  # };

  # ---

  xdg.portal = {
    enable = true;
    config = {
      sway = {
        default = [
          "wlr"
          "gtk"
        ];
      };
    };
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
    wlr.enable = true;
  };

  hardware = {
    # Required for sway to start
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment = {
    sessionVariables = {
      EDITOR = "hx";
      # it puts into $HOME/go by default
      GOPATH = "$HOME/.go";
      # fixes invisible cursors in Sway
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };

  ### Fonts

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
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

  # To set up Sway using Home Manager, first you must enable Polkit in your nix configuration: https://wiki.nixos.org/wiki/Sway
  security.polkit.enable = true;

  users.users.${username} = {
    initialPassword = "e";
    uid = user_id;
    isNormalUser = true;
    extraGroups = [
      # allow using `sudo`
      "wheel"
      # allow configuring wifi
      "networkmanager"
    ];
    shell = pkgs.u.nushell;
  };

  networking = {
    hostName = "nixos";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  services = {
    blueman.enable = true;
    libinput.enable = true;
    # adds all executables to /usr/bin to be able to run
    # various scripts on NixOS
    envfs.enable = true;
    # required for Vial (keyboard configurator)
    udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };

  ### Locale

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  ### Sound

  # rtkit is optional but recommended https://wiki.nixos.org/wiki/PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    package = pkgs.u.pipewire;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ### Kernel

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  systemd.timers."daily-shutdown" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "23:00";
      Persistent = true;
    };
  };

  systemd.services."daily-shutdown" = {
    script = ''
      /run/current-system/sw/bin/systemctl poweroff
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["btusb" "mt7921e"];
    kernelParams = [
      "quiet"
    ];
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    # see instructions in README for how to configure LUKS encryption
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-partlabel/root";
  };

  system.stateVersion = "25.05";
}
