{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    function prompt_bwrap() {
      [[ -n $BWRAP_SESSION ]] && p10k segment -f 208 -t '(nwrap)'
    }
    function prompt_zmx() {
      [[ -n $ZMX_SESSION ]] && p10k segment -f 033 -t "$ZMX_SESSION"
    }
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(bwrap zmx "''${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}")
  '';
}
