{ config, ... }:
{
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Modesetting is required.
    modesetting.enable = true;
    # I have an old nvidia GPU (9 years ago)
    open = false;
  };
}
