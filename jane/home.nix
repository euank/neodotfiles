{ config, pkgs, ... }:

let
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

  programs.neovim = {
    enable = true;
    withPython3 = true;
    withNodeJs = true;
    package = pkgs.neovim;
    extraConfig = "source ${../shared/vim/vimrc}";
    plugins = with pkgs.vimPlugins; [
      ({
        plugin = vim-airline;
        config = ''
          let g:airline#extensions#tabline#enabled = 1
          let g:airline#extensions#tabline#left_sep = ' '
          let g:airline#extensions#tabline#left_alt_sep = '¦'
          let g:airline#extensions#tabline#buffer_idx_mode = 1
        '';
      })
      vim-surround
      vim-repeat
      vim-dispatch
      vim-eunuch
      vim-sleuth
      denite-nvim
      ({
        plugin = deoplete-nvim;
        config = ''
          let g:deoplete#enable_at_startup = 1
          set completeopt=noselect
        '';
      })
      deoplete-lsp
      vim-nix
      ({
        plugin = vim-colorschemes;
        config = ''
          let g:inkpot_black_background = 1
          colorscheme inkpot
        '';
      })
      ({
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          local configs = require'lspconfig'

          configs.gopls.setup{
            cmd = {'gopls', '-remote=auto'},
            init_options = { },
          }

          configs.rust_analyzer.setup({})
          configs.tsserver.setup{}
          EOF
        '';
      })
    ];
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
