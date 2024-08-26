{
  description = "euank nix dotfile flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    vim-skkeleton.url = "github:euank/nixpkgs/vim-plugin-skkeleton-2024-02-22";
    vim-pum.url = "github:euank/nixpkgs/vim-plugin-pum-2024-08-23";
    vim-ddc.url = "github:euank/nixpkgs/vim-plugins-ddc-2024-08-23";
    home-manager.url = "github:nix-community/home-manager";
    ekverlay.url = "github:euank/nixek-overlay";
    nixek.url = "github:nixek-systems/pkgs";
    mvn2nix.url = "github:fzakaria/mvn2nix";
    # gradle2nix.url = "github:tadfisher/gradle2nix";
    # dwarffs.url = "github:edolstra/dwarffs";
    # nickel.url = "github:tweag/nickel";

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
          (final: prev: {
            gopls = prev.gopls.override { buildGoModule = final.buildGo123Module; };
            # temporarily for https://github.com/NixOS/nixpkgs/pull/334858
            mvn2nix = mvn2nix.defaultPackage.x86_64-linux;
            # gradle2nix = gradle2nix.defaultPackage.x86_64-linux;
            # nickel = inputs.nickel.packages.x86_64-linux.default;
            vimPlugins = prev.vimPlugins.extend (
              final: prev: {
                inherit (inputs.vim-skkeleton.legacyPackages.x86_64-linux.vimPlugins) skkeleton;
                inherit (inputs.vim-pum.legacyPackages.x86_64-linux.vimPlugins) pum-vim;
                inherit (inputs.vim-ddc.legacyPackages.x86_64-linux.vimPlugins)
                  ddc-vim
                  ddc-source-lsp
                  ddc-filter-matcher_head
                  ddc-filter-sorter_rank
                  ddc-ui-native
                  ddc-ui-pum
                  ;
              }
            );
          })
        ];
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      inherit pkgs;

      formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

      nixosConfigurations = {
        Enkidudu = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./enkidudu/configuration.nix ];
        };
        jane = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./jane/configuration.nix ];
        };
        pascal = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./pascal/configuration.nix ];
        };

        rolivaw = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./rolivaw/configuration.nix ];
        };

        demerzel = nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./demerzel/configuration.nix ];
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
          updateInputFlags = lib.strings.concatMapStringsSep " " (s: "--update-input ${s}") pubInputs;
        in
        pkgs.writeShellScriptBin "nix-flake-update" ''
          export PATH=$PATH:${pkgs.nix}/bin
          set -x
          if [[ "$(nix --version)" = *Lix* ]]; then
            nix flake update ${lib.strings.concatStringsSep " " pubInputs}
          else
            nix flake lock ${updateInputFlags}
          fi
          set +x
        '';
    };
}
