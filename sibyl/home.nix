{ config, pkgs, ... }:

{
  imports = [
    ../shared/home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [
    stdenv.cc.cc.lib
    ninja
    restic
  ];

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  programs.zsh = {
    enable = true;
    history = {
      save = 1000000;
    };
    shellAliases = {
      ls = "ls --color=auto";
      k = "kubectl";
    };
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source "${../shared/zsh/p10k.zsh}"
      source "${../shared/zsh/zshrc}"

      export NGROK_HOME=/home/esk/dev/ngrok
      source "/home/esk/dev/ngrok/.cache/ngrok-host-shellhook"
    '';
  };
}
