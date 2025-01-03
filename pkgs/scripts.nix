{ pkgs }:
{
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    #!/bin/sh -e

    selection="$(${pkgs.hacksaw}/bin/hacksaw -f "-i %i -g %g")"
    ${pkgs.shotgun}/bin/shotgun $selection - | ${pkgs.xclip}/bin/xclip -t 'image/png' -selection clipboard
  '';

}
