{ config, pkgs, ... }:

{

  imports = [
    ../shared/home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [ ];

  programs.alacritty = {
    enable = true;
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
      # enableFlakes = true;
    };
  };

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  services.gpg-agent = {
    enable = false;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  services.picom.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
