{ lib, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    function prompt_bwrap() {
      [[ -n $BWRAP_SESSION ]] && p10k segment -f 208 -t '(nwrap)'
    }
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(bwrap "''${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]}")
  '';
}
