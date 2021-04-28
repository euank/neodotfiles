{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-20.09";
    home-manager.url = "github:nix-community/home-manager";
    nixek.url = "github:euank/nixek-overlay";
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, nixek, home-manager }:
    let
      pcscd-overlay = final: prev: {
        # the one in unstable has a bug at the time of writing that I haven't
        # bothered debugging yet. Service fails to start with errors, easy to
        # repro at least.
        pcscd = (import nixpkgs-stable { system = "x86_64-linux"; }).pkgs.pcscd;
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          nixek.overlay
          pcscd-overlay
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
