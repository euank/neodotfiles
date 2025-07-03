{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:euank/home-manager/ssh-agent-change";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    # gradle2nix.url = "github:tadfisher/gradle2nix";
    # dwarffs.url = "github:edolstra/dwarffs";
    nickel.url = "github:tweag/nickel";

    # https://github.com/NixOS/nixpkgs/pull/392737
    anki.url = "github:euank/nixpkgs/anki-2025-05-20";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Magic unimportable things
    ngrok-dev.url = "git+file:/home/esk/dev/ngrok?dir=nix";
    ngrok-dev2.url = "path:/home/esk/nix-ngrok-dev";
    secrets.url = "path:/home/esk/dev/nix-secrets";
  };

  outputs =
    {
      nixpkgs,
      mvn2nix,
      nixek,
      ekverlay,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlays.default
          nixek.overlay
          inputs.niri.overlays.niri
          (
            final: prev:
            {
              inherit (inputs.anki.legacyPackages."${system}") anki;
              newer-linux-firmware = final.linux-firmware.overrideAttrs (old: {
                version = "f2e9c60ae3";
                src = final.fetchgit {
                  name = "linux-firmware";
                  url = "https://gitlab.com/kernel-firmware/linux-firmware.git";
                  rev = "f2e9c60ae3116e82c12d2ee675a24fef5e3f1a45";
                  hash = "sha256-ZK9vgginLnD93r2KY9sveqbXsCKIwoFwvQ4berUpz+8=";
                };
              });

              # temporarily for https://github.com/NixOS/nixpkgs/pull/334858
              mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
              # gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
              nickel = inputs.nickel.packages.x86_64-linux.default;
              vlc = prev.vlc.override {
                libbluray = prev.libbluray.override {
                  withAACS = true;
                  withBDplus = true;
                };
              };
            }
            // (import ./pkgs/scripts.nix { pkgs = final; })
          )
        ];
        config = {
          allowUnfree = true;
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
