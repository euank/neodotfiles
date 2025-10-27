{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-claude.url = "github:euank/nixpkgs/claude-squad";
    nixpkgs-amp.url = "github:euank/nixpkgs/amp-cli-writeShellApplication";
    nixpkgs-maestral.url = "github:euank/nixpkgs/maestral-updates-2025-10-24";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    # gradle2nix.url = "github:tadfisher/gradle2nix";
    # dwarffs.url = "github:edolstra/dwarffs";

    niri = {
      url = "github:euank/niri-flake/newer-polkit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Magic unimportable things
    ngrok-dev.url = "git+file:/home/esk/dev/ngrok?dir=nix";
    ngrok-dev2.url = "path:/home/esk/nix-ngrok-dev";
    secrets.url = "path:/home/esk/dev/nix-secrets";
  };

  outputs =
    {
      self,
      nixpkgs,
      mvn2nix,
      nixek,
      ekverlay,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      ampcode =
        (import inputs.nixpkgs-amp {
          inherit system;
          config.allowUnfree = true;
        }).ampcode;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlays.default
          nixek.overlay
          inputs.niri.overlays.niri
          (
            final: prev:
            {
              inherit (inputs.nixpkgs-claude.legacyPackages."${system}") claude-squad;
              inherit (inputs.nixpkgs-maestral.legacyPackages."${system}") maestral;
              inherit ampcode;
              mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            }
            // (import ./pkgs/scripts.nix { pkgs = final; })
          )
        ];
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # temporarily, https://github.com/NixOS/nixpkgs/issues/429268
            "libsoup-2.74.3"
          ];
        };
      };
    in
    {
      inherit pkgs;

      formatter.x86_64-linux = pkgs.nixfmt-tree;

      nixosConfigurations = {
        Enkidudu = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.niri.nixosModules.niri
            ./enkidudu/configuration.nix
          ];
        };
        sibyl = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./sibyl/configuration.nix
          ];
        };
        jane = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./jane/configuration.nix
          ];
        };
        pascal = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.niri.nixosModules.niri
            ./pascal/configuration.nix
          ];
        };

        martin = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            inputs.niri.nixosModules.niri
            ./martin/configuration.nix
          ];
        };

        demerzel = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.niri.nixosModules.niri
            ./demerzel/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        euan = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs pkgs; };
          modules = [
            (
              { ... }:
              {
                home.username = "euan";
                home.homeDirectory = "/home/euan";
              }
            )
            ./shared/home.nix
          ];
        };
        esk = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs pkgs; };
          modules = [
            (
              { ... }:
              {
                home.username = "esk";
                home.homeDirectory = "/home/esk";
              }
            )
            ./shared/home.nix
          ];
        };
      };

      # nix-flake-update is an update script for updating the subset of flake
      # inputs that are available publicly.
      # It filters out specific inputs that aren't always present
      nix-flake-update =
        with pkgs;
        let
          pubInputs = lib.subtractLists [
            "self"
            "ngrok-dev"
            "ngrok-dev2"
            "secrets"
          ] (lib.attrNames inputs);
        in
        pkgs.writeShellScriptBin "nix-flake-update" ''
          export PATH=$PATH:${pkgs.nix}/bin
          set -x
          nix flake update ${lib.strings.concatStringsSep " " pubInputs}
          set +x
        '';
    };
}
