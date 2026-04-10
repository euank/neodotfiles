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

  # gpt-5.2 based on https://github.com/euank/kitchen-sink/tree/0ac3b084231c3e0cd40ff7686cd3a8e9ad9b3527/model-comparison
  llm-ocr-area = pkgs.writeShellScriptBin "llm-ocr-area" ''
    selection="$(${slurp}/bin/slurp)"
    ${grim}/bin/grim -g "$selection" - | ${llm}/bin/llm -m "gpt-5.2" -a - "Please output your best guess at the Japanese characters in this image. Do not output any other text." | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

}
