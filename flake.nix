{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-20.09";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, nixek, ekverlay, home-manager }:
    let
      stable = import nixpkgs-stable { system = "x86_64-linux"; };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          ekverlay.overlay
          nixek.overlay
        ];
        config = { allowUnfree = true; };
      };
      scdaemonUdevRev = "01898735a015541e3ffb43c7245ac1e612f40836";
      scdaemonRules = builtins.fetchurl {
        url = "https://salsa.debian.org/debian/gnupg2/-/blob/${scdaemonUdevRev}/debian/scdaemon.udev";
        sha256 = "0zii2zgfjmifc6m4zdzx7pk5p42g3ll683vcy2761na88syag2qh";
      };
      scdaemonUdevRulesPkg = pkgs.runCommandNoCC "scdaemon-udev-rules" {} ''
        loc="$out/lib/udev/rules.d/"
        mkdir -p "''${loc}"
        cp "${scdaemonRules}" "''${loc}/60-scdaemon.rules"
      '';
    in {
    nixosConfigurations = rec {
      Enkidudu = nixpkgs.lib.nixosSystem rec {
        inherit pkgs;
        system = "x86_64-linux";
        modules = [
          ./enkidudu/configuration.nix
          home-manager.nixosModules.home-manager
          { services.udev.packages = [ scdaemonUdevRulesPkg ]; }
        ];
      };
    };
  };
}
