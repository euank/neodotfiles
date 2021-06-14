{ config, pkgs, ... }:

let
  # for lsp server support, remove once nvim is 0.5 in nixpkgs
  # and msgpack 1.0
  nightlyNvimNix = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/48d6448ec2bcef0c29cdf91a4339dcb2fa0b0f02.tar.gz";
    sha256 = "1gla32h0scxd0dixg44cbc90lcfdvk33154amw43b2mvi9nk9h3n";
  }) {
    system = "x86_64-linux";
  });
  nightlyNvim = nightlyNvimNix.neovim.override {
    extraPython3Packages = (ps: [ ps.msgpack ]);
    withNodeJs = true;
  };
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
  };
in
{
  home.packages = with pkgs; [
    pwgen
    k3s
    wireguard
    redis
    perf-tools

    # dev stuff
    bind
    binutils
    exa
    file
    fish
    gnumake
    go_1_16
    lorri
    gradle
    htop
    (hiPrio clang)
    gcc
    x11
    jq
    kubectl
    kubernetes-helm
    nightlyNvim
    nixpkgs-fmt
    ngrok-2
    openssl
    nodejs
    pkg-config
    cmake
    vagrant
    iptables
    tmate
    lsof
    tcpdump
    rust-analyzer
    python3
    ripgrep
    ruby
    rustup
    sqlite
    sshfs
    tig
    tmux
    tree
    gopls
    unzip
    zsh-powerlevel10k
    nodePackages.typescript-language-server

    # boot
    sbsigntool
    efitools
  ];

  home.sessionVariables = sessionVariables;

  programs.alacritty = {
    enable = true;
  };

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    history = {
      save = 1000000;
    };
    sessionVariables = sessionVariables;
    shellAliases = {
      ls = "ls --color=auto";
      k = "kubectl";
    };
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source "${../shared/zsh/p10k.zsh}"
      source "${../shared/zsh/zshrc}"
    '';
  };
  programs.git = {
    enable = true;
    userName = "Euan Kemp";
    userEmail = "euan@ngrok.com";
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  services.gpg-agent = {
    enable = false;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
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
