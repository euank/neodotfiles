{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # https://github.com/NixOS/nixpkgs/pull/479716
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    # gradle2nix.url = "github:tadfisher/gradle2nix";
    # dwarffs.url = "github:edolstra/dwarffs";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Magic unimportable things
    ngrok-dev.url = "path:/home/esk/nix-ngrok-dev";
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
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ekverlay.overlays.default
          nixek.overlay
          inputs.niri.overlays.niri
          (
            final: prev:
            {
              inherit (inputs.noctalia.legacyPackages."${system}") noctalia;

              mpv-unwrapped = prev.mpv-unwrapped.override {
                libbluray = prev.libbluray.override {
                  withAACS = true;
                  withBDplus = true;
                };
              };

              mpv = prev.mpv.override {
                mpv-unwrapped = final.mpv-unwrapped;
                youtubeSupport = false;
              };

              mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
              rf = import ./pkgs/rf.nix { pkgs = final; };
              linear-cli = import ./pkgs/linear-cli.nix { pkgs = final; };
              python3 = prev.python3.override {
                packageOverrides = import ./pkgs/python-package-overrides.nix {
                  inherit final inputs;
                };
              };
              python3Packages = final.python3.pkgs;
              llm = import ./pkgs/llm.nix {
                llmBase = final.python3.pkgs.llm;
                pkgs = final;
              };
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
            ./esk/home.nix
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
