{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-20.09";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    gradle2nix.url = "github:tadfisher/gradle2nix";
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, mvn2nix, gradle2nix, nixek, nix, ekverlay, home-manager }:
    let
      stable = import nixpkgs-stable {
        system = "x86_64-linux";
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          ekverlay.overlay
          nixek.overlay
          (final: prev: {
            mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
          })
        ];
        config = { allowUnfree = true; };
      };
    in {
    nixosConfigurations = rec {
      Enkidudu = nixpkgs.lib.nixosSystem rec {
        inherit pkgs;
        system = "x86_64-linux";
        modules = [
          ./enkidudu/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
