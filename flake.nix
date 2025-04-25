{
  inputs = {
    # I don't want to keep hardware configuration file with my main configs
    hardware-configuration = {
      url = "path:/etc/nix/hardware.nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # contains stuff like firefox extensions
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # why flake: makes it easy for me to use my software
    patchy.url = "github:NikitaRevenco/patchy/main";
    # why flake: makes it easy for me to use my software
    ferrishot.url = "github:nik-rev/ferrishot/main";
    # why flake: My fork uses custom merged PRs that I want to use.
    helix.url = "github:helix-editor/helix/master";
    # why flake: I can use Yazi right inside of helix
    yazi.url = "github:sxyazi/yazi/main";
    # why flake: wezterm has some issues with Sway which were fixed in the latest versions
    wezterm.url = "github:wez/wezterm?dir=nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nur,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlays.default
          # unstable nixpkgs
          (final: prev: {
            u = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          })
        ];
      };
      specialArgs = {
        inherit inputs pkgs;
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
              backupFileExtension = "hm-backup";
              users.e.imports = [
                ./home.nix
              ];
            };
          }
        ];
      };
    };
}
