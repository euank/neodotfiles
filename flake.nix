{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    denops-nixpkgs.url = "github:euank/nixpkgs/add-denops-2023-10-23";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    # gradle2nix.url = "github:tadfisher/gradle2nix";
    dwarffs.url = "github:edolstra/dwarffs";
    # nickel.url = "github:tweag/nickel";

    # Magic unimportable things
    ngrok-dev.url = "git+file:/home/esk/dev/ngrok?dir=nix";
    ngrok-dev2.url = "path:/home/esk/nix-ngrok-dev";
    secrets.url = "path:/home/esk/dev/nix-secrets";
  };

  outputs =
    { nixpkgs, mvn2nix, nixek, ekverlay, dwarffs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlays.default
          nixek.overlay
          (final: prev: {
            mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            # gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
            dwarffs = dwarffs.defaultPackage.x86_64-linux;
            vimPlugins = inputs.denops-nixpkgs.legacyPackages.x86_64-linux.vimPlugins;
            # nickel = inputs.nickel.packages.x86_64-linux.default;

          })
        ];
        config = { allowUnfree = true; };
      };
    in
    {
      inherit pkgs;

      nixosConfigurations = {
        Enkidudu = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./enkidudu/configuration.nix
          ];
        };
        jane = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./jane/configuration.nix
          ];
        };
        pascal = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./pascal/configuration.nix
          ];
        };

        rolivaw = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./rolivaw/configuration.nix
          ];
        };

        demerzel = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./demerzel/configuration.nix
          ];
        };
      };

      # nix-flake-update is an update script for updating the subset of flake
      # inputs that are available publicly.
      # It filters out specific inputs that aren't always present
      nix-flake-update = with pkgs; let
        pubInputs = lib.subtractLists [ "self" "ngrok-dev" "ngrok-dev2" "secrets" ] (lib.attrNames inputs);
        updateInputFlags = lib.strings.concatMapStringsSep " " (s: "--update-input ${s}") pubInputs;
      in
      pkgs.writeScriptBin "nix-flake-update" ''
        export PATH=$PATH:${pkgs.nix}/bin
        set -x
        nix flake lock ${updateInputFlags}
        set +x
      '';
    };
}
