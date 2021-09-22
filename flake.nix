{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim.url = "github:neovim/neovim?dir=contrib";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-20.09";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    gradle2nix.url = "github:tadfisher/gradle2nix";
    dwarffs.url = "github:edolstra/dwarffs";

    # Magic unimportable things
    ngrok-dev.url = "path:/home/esk/dev/ngrok/nix";
    secrets.url = "path:/home/esk/dev/nix-secrets";
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, mvn2nix, gradle2nix, nixek, nix, ekverlay, home-manager, dwarffs, ... }@inputs:
    let
      system = "x86_64-linux";
      stable = import nixpkgs-stable {
        inherit system;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlay
          nixek.overlay
          (final: prev: {
            mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
            dwarffs = dwarffs.defaultPackage.x86_64-linux;
            neovim = inputs.neovim.defaultPackage.x86_64-linux;
          })
        ];
        config = { allowUnfree = true; };
      };
    in
    {
      nixosConfigurations = rec {
        Enkidudu = nixpkgs.lib.nixosSystem rec {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./enkidudu/configuration.nix
          ];
        };
        jane = nixpkgs.lib.nixosSystem rec {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./jane/configuration.nix
          ];
        };
      };

      # nix-flake-update is an update script for updating the subset of flake
      # inputs that are available publicly.
      # It filters out specific inputs that aren't always present
      nix-flake-update = with pkgs; let
        pubInputs = lib.subtractLists [ "ngrok-dev" "secrets" ] (lib.attrNames inputs);
        updateInputFlags = lib.strings.concatMapStringsSep " " (s: "--update-input ${s}") pubInputs;
      in
      pkgs.writeScriptBin "nix-flake-update" ''
        export PATH=$PATH:${pkgs.nixFlakes}/bin
        set -x
        nix flake lock ${updateInputFlags}
        set +x
      '';

    };
}
