{
  inputs = {
    # I don't want to keep hardware configuration file with my main configs
    hardware-configuration = {
      url = "path:/etc/nix/hardware.nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.05";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    patchy.url = "github:NikitaRevenco/patchy/main";
    # why flake: My fork uses custom merged PRs that I want to use.
    helix.url = "github:NikitaRevenco/helix/patchy";
    # why flake: I can use Yazi right inside of helix
    yazi.url = "github:sxyazi/yazi/main";
    # why flake: wezterm has some issues with Sway which were fixed in the latest versions
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-old,
      nur,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-nur = import nixpkgs-unstable {
        inherit system;
        overlays = [ nur.overlays.default ];
      };
      specialArgs = {
        inherit pkgs-unstable inputs pkgs-nur;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              extraSpecialArgs = specialArgs;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.e.imports = [
                ./home.nix
              ];
            };
          }
        ];
      };
    };
}
