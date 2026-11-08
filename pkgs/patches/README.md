# niri RemoteDesktop

`niri-remote-desktop.patch` is the complete diff for upstream PR
https://github.com/niri-wm/niri/pull/1966, pinned to:

- Base: `d0cd58ec5ac6b2d41d42478fb4f3cc7c0c687db9` (niri-wm/niri)
- Head: `4305f1040f16d275947496516728fe5b890a251e` (axelkar/niri)
- Download: https://github.com/niri-wm/niri/compare/d0cd58ec5ac6b2d41d42478fb4f3cc7c0c687db9...4305f1040f16d275947496516728fe5b890a251e.diff

The flake pins the upstream base and applies this local patch before importing
Cargo.lock, because the patch changes Rust dependencies too. It implements
Mutter RemoteDesktop for xdg-desktop-portal-gnome, retaining portal permission
dialogs instead of installing a permissionless virtual-input backend.

This is an unmerged upstream patch. Remove the pin and override once equivalent
support ships upstream. Activating a new package requires restarting the niri
session (save work, log out and back in), not merely reloading its config.
