{ pkgs, ... }:

{
  imports = [ ../shared/desktop-home.nix ];
  home.packages = [ pkgs.brightnessctl ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";
}
