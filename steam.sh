#!/usr/bin/env bash

set -eux

nix build -o steam '.#nixosConfigurations.Enkidudu.pkgs.steam'

./steam/bin/steam
