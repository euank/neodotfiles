{ pkgs }:
let
  inherit (pkgs)
    grim
    slurp
    llm
    wl-clipboard
    ;
in
{
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    selection="$(${slurp}/bin/slurp)"
    ${grim}/bin/grim -g "$selection" - | ${wl-clipboard}/bin/wl-copy -t "image/png"
  '';

  llm-ocr-area = pkgs.writeShellScriptBin "llm-ocr-area" ''
    selection="$(${slurp}/bin/slurp)"
    ${grim}/bin/grim -g "$selection" - | ${llm}/bin/llm -m "gpt-4o" -a - "Please output your best guess at the Japanese characters in this image. Do not output any other text." | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

}
