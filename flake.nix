{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      laptop-asus-vivobook-16 = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ./hardware-configuration/laptop-asus-vivobook-16.nix ];
      };
    };
  };
}
