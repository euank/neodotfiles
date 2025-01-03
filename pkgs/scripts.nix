{ pkgs }:
{
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    #!/bin/sh -e

    selection="$(${pkgs.hacksaw}/bin/hacksaw -f "-i %i -g %g")"
    ${pkgs.shotgun}/bin/shotgun $selection - | ${pkgs.xclip}/bin/xclip -t 'image/png' -selection clipboard
  '';

  llm-ocr-area = pkgs.writeShellScriptBin "llm-ocr-area" ''
    #!/bin/sh -e

    selection="$(${pkgs.hacksaw}/bin/hacksaw -f "-i %i -g %g")"
    ${pkgs.shotgun}/bin/shotgun $selection - | ${pkgs.llm}/bin/llm -m "gpt-4o" -a - "Please output your best guess at the Japanese characters in this image. Do not output any other text." | ${pkgs.xclip}/bin/xclip -selection clipboard
  '';

}
