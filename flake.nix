{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    denops-nixpkgs.url = "github:euank/nixpkgs/add-denops-2022-09-04";
    neovim = {
      url = "github:neovim/neovim/release-0.8?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    gradle2nix.url = "github:tadfisher/gradle2nix";
    dwarffs.url = "github:edolstra/dwarffs";

    # Magic unimportable things
    ngrok-dev.url = "path:/home/esk/dev/ngrok/nix";
    ngrok-dev2.url = "path:/home/esk/nix-ngrok-dev";
    secrets.url = "path:/home/esk/dev/nix-secrets";
  };

  outputs =
    { self, nixpkgs, mvn2nix, gradle2nix, nixek, nix, ekverlay, home-manager, dwarffs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlays.default
          nixek.overlay
          (final: prev: {
            mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
            dwarffs = dwarffs.defaultPackage.x86_64-linux;
            neovim = inputs.neovim.defaultPackage.x86_64-linux;
            vimPlugins = inputs.denops-nixpkgs.legacyPackages.x86_64-linux.vimPlugins;
          })
        ];
        config = { allowUnfree = true; };
      };
    in
    {
      inherit pkgs;

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

        rolivaw = nixpkgs.lib.nixosSystem rec {
          inherit pkgs system;
          specialArgs = { inherit inputs; };
          modules = [
            ./rolivaw/configuration.nix
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
