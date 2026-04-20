{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    function prompt_bwrap() {
      [[ -n $BWRAP_SESSION ]] && p10k segment -f 208 -t '(nwrap)'
    }
    function prompt_shpool() {
      [[ -n $SHPOOL_SESSION_NAME ]] && p10k segment -f 033 -t "$SHPOOL_SESSION_NAME"
    }
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(bwrap shpool "''${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}")
  '';
}
