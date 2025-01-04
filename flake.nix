{
  inputs = {
    hardware-configuration = {
      url = "path:/etc/nix/hardware.nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.05";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix.url = "github:NikitaRevenco/helix/patchy";
    patchy.url = "github:NikitaRevenco/patchy/main";
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    playwright.url = "github:pietdevries94/playwright-web-flake/1.47.0";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-old,
      nur,
      playwright,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        inherit (playwright.packages.${system}) playwright-driver playwright-test;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
      pkgs-old = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
      specialArgs = {
        inherit pkgs-unstable inputs pkgs-old;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./configuration.nix
          nur.nixosModules.nur
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.backupFileExtension = "backup";
            home-manager.users.e = {
              imports = [
                ./home.nix
                inputs.nur.hmModules.nur
              ];
            };
          }
        ];
      };
    };
}
