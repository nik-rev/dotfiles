{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # contains stuff like firefox extensions
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # why flake: makes it easy for me to use my software
    patchy.url = "github:nik-rev/patchy/main";
    # why flake: makes it easy for me to use my software
    lumina.url = "github:nik-rev/lumina/v0.1.0";
    # why flake: makes it easy for me to use my software
    ferrishot.url = "github:nik-rev/ferrishot/main";
    # why flake: My fork uses custom merged PRs that I want to use.
    helix.url = "github:helix-editor/helix/master";
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
      hostSpecificConfigs = {
        laptop = [
          ./nix-hardware/laptop.nix
          ./nix-hardware/nvidia.nix
        ];
      };

      mkNixosConfiguration =
        hostSpecific:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs.inputs = inputs;
          modules = [
            {
              nixpkgs.overlays = [
                nur.overlays.default
                # unstable nixpkgs
                (final: prev: {
                  u = import nixpkgs-unstable {
                    inherit system;
                    # Without this we get an error message in discord:
                    #
                    # > "You can't use speech synthesis because
                    # > speech dispatcher won't open"
                    config.firefox.speechSynthesisSupport = true;
                  };
                })
              ];
            }
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs.inputs = inputs;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                users.e.imports = [
                  ./home.nix
                ];
              };
            }
          ] ++ hostSpecific;
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames hostSpecificConfigs) (
        name: mkNixosConfiguration (hostSpecificConfigs.${name})
      );
    };
}
