{
  description = "euank nix dotfile flakes";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
  { self, nixpkgs, home-manager }: {
    nixosConfigurations = rec {
      Enkidudu = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./enkidudu/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
