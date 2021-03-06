{
  config,
  pkgs,
  ...
}:

let
  # nixatom = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/b8988e13be291029c72b76549d70c783856f2dc3.tar.gz") {};
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH =
      "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig:${pkgs.sqlite.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig:${pkgs.pam}/lib/pkgconfig:${pkgs.elfutils.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";
    # maptool
    PROTOC_3_7 = "${pkgs.protobuf3_7}/bin/protoc";
  };
  ibus = pkgs.ibus-with-plugins.override { plugins = with pkgs.ibus-engines; [ mozc uniemoji ]; };

  muttoauth2 = pkgs.writeShellApplication {
    name = "muttoauth2";
    runtimeInputs = with pkgs; [ python3 mutt ];
    text = ''
      python3 ${pkgs.mutt}/share/doc/mutt/samples/mutt_oauth2.py "$@"
    '';
  };
in
{
  home.packages = with pkgs; [
    alejandra
    anki-bin
    bemenu
    binutils
    blender
    blueman
    borgbackup
    ceph
    cfssl
    # chromium
    cntr
    deluge
    discord
    diskonaut
    escrotum
    evince
    feh
    # ffmpeg-full
    file
    firefox
    fish
    flyctl
    gimp
    gmrun
    gnome3.cheese
    htop
    inkscape
    shotcut
    ibus
    jmtpfs
    jq
    k3s
    keepassxc
    kubectl
    kubernetes-helm
    mpv
    muttoauth2
    neomutt
    ngrok
    nitrogen
    nix-index
    nixpkgs-fmt
    nmap
    # obs-studio
    openssl
    p7zip
    pass
    pavucontrol
    pwgen
    ripgrep
    rust-analyzer
    scrot
    signal-desktop
    sqlite
    sqlite.dev
    sshfs
    syncplay
    tig
    tint2
    tmux
    tor-browser-bundle-bin
    tree
    unzip
    wasm-pack
    wireguard-tools
    xorg.xkill
    xorg.xwininfo
    xwayland
    yacreader
    youtube-dl
    yt-dlp
    zsh-powerlevel10k

    # dev stuff
    (hiPrio clang)
    # For maptool, we'll deal with packaging it again properly later
    awscli2
    bc
    bind
    binutils
    bison
    cmake
    deno
    elfutils
    flex
    gcc
    gdb
    gh
    gnumake
    go_1_18
    gopls
    gradle
    # ipmiview
    openjdk
    # javaPackages.compiler.openjdk16
    nodejs
    coldsnap
    crd2pulumi
    gradle2nix
    jetbrains.idea-community
    kpt
    kube2pulumi
    linuxPackages.perf
    mvn2nix
    ncurses
    nodePackages.typescript-language-server
    perf-tools
    pkg-config
    pulumi
    pulumi-sdk
    python3
    qt5Full
    ruby
    rustup
    terraform
    trace-cmd

    # game related
    desmume
    # maptool
    melonDS
    minecraft

    # misc
    efitools
    sbsigntool
  ];

  home.sessionVariables = sessionVariables;

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        # TERM = "xterm-256color";
      };
      font = {
        normal = {
          family = "MesloLGS NF";
        };
      };
      colors = {
        primary = {
          background= "#000000";
          foreground= "#eaeaea";
          dim_foreground= "#9a9a9a";
          bright_foreground= "#ffffff";
        };
        normal = {
          black=   "#000000";
          red=     "#d54e53";
          green=   "#b9ca4a";
          yellow=  "#e6c547";
          blue=    "#7aa6da";
          magenta= "#c397d8";
          cyan=    "#70c0ba";
          white=   "#eaeaea";
        };
      };
    };
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
    userEmail = "euank@" + "euan" + "k.com";
    aliases = {
      co = "checkout";
      s = "status";
    };
    extraConfig = {
      merge.tool = "vimdiff";
      "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

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
          let g:airline#extensions#tabline#left_alt_sep = '??'
          let g:airline#extensions#tabline#buffer_idx_mode = 1
        '';
      })
      vim-surround
      vim-repeat
      vim-dispatch
      vim-eunuch
      vim-sleuth
      denops-vim
      ({
        plugin = skkeleton;
        config = ''
          imap <C-j> <Plug>(skkeleton-toggle)
          cmap <C-j> <Plug>(skkeleton-toggle)
        '';
      })
      ({
        plugin = pum-vim;
        config = ''
          inoremap <C-n>   <Cmd>call pum#map#insert_relative(+1)<CR>
          inoremap <C-p>   <Cmd>call pum#map#insert_relative(-1)<CR>
          inoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
          inoremap <C-e>   <Cmd>call pum#map#cancel()<CR>
          inoremap <PageDown> <Cmd>call pum#map#insert_relative_page(+1)<CR>
          inoremap <PageUp>   <Cmd>call pum#map#insert_relative_page(-1)<CR>
        '';
      })
      ddc-sorter_rank
      ddc-matcher_head
      ddc-nvim-lsp
      ({
        plugin = ddc-vim;
        # TODO
        config = ''
          set completeopt=menuone,noinsert,noselect
          set shortmess+=c
          call ddc#custom#patch_global('completionMenu', 'pum.vim')
          call ddc#custom#patch_global('sources', ['nvim-lsp'])
          call ddc#custom#patch_global('sourceOptions', {
          \ '_': { 'matchers': ['matcher_head'], 'sorters': ['sorter_rank'] },
          \ 'nvim-lsp': {
          \   'mark': 'lsp',
          \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
          \ })

          call ddc#custom#patch_global('sourceParams', {
          \ 'nvim-lsp': { 'kindLabels': { 'Class': 'c' } },
          \ })

          call ddc#enable()
        '';
      })
      vim-nix
      ({
        plugin = vim-colorschemes;
        config = ''
          let g:inkpot_black_background = 1
          colorscheme inkpot
        '';
      })
      # Used in nvim-lspconfig below
      rust-tools-nvim
      ({
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          local configs = require'lspconfig'

          configs.gopls.setup{
            cmd = {'gopls', '-remote=auto'},
            init_options = {
              staticcheck = false,
            },
          }

          configs.rust_analyzer.setup({})
          configs.tsserver.setup{}

          local opts = {
            tools = {},
            server = {
              settings = {
                ["rust-analyzer"] = {
                    checkOnSave = {
                        command = "clippy"
                    },
                }
              }
            },
          }

          require('rust-tools').setup(opts)

          EOF
        '';
      })
      ({
        plugin = vim-fugitive;
        config = ''
          nnoremap <silent> <leader>gs :Gstatus<CR>
          nnoremap <silent> <leader>gd :Gdiff<CR>
          nnoremap <silent> <leader>gc :Gcommit<CR>
          nnoremap <silent> <leader>gb :Gblame<CR>
          nnoremap <silent> <leader>gl :Glog<CR>
          nnoremap <silent> <leader>gp :Git push<CR>
          nnoremap <silent> <leader>gw :Gwrite<CR>
          nnoremap <silent> <leader>gr :Gremove<CR>
          autocmd BufReadPost fugitive://* set bufhidden=delete
        '';
      })
      vim-rhubarb
      # vim-ripgrep
      ({
        plugin = vim-go;
        config = ''
          filetype plugin indent on
          let g:go_fmt_command = "goimports"
          let g:go_rename_command = "gopls"
          let g:go_def_mode = 'gopls'
          let g:go_fmt_options = {
          \ 'gofmt': '-s',
          \ 'goimports': '-local go.ngrok.com',
          \ }
          let g:go_highlight_functions = 1
          let g:go_highlight_methods = 1
          let g:go_highlight_structs = 1
          let g:go_highlight_operators = 1
          let g:go_highlight_build_constraints = 1
        '';
      })
      ({
        plugin = ale;
        config = ''
          let g:ale_rust_cargo_check_all_targets = 1
          let g:ale_fixers = ['rustfmt', 'eslint']
          let g:ale_fix_on_save = 1
          let g:ale_fixers = {
          \   '*': ['remove_trailing_lines', 'trim_whitespace'],
          \   'typescript': ['eslint'],
          \}
          let g:ale_linters = { 'haskell': ['stack-ghc', 'stack-build']}
        '';
      })
    ];
  };

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
  };

  services.blueman-applet.enable = true;

  services.dropbox.enable = true;

  services.picom.enable = true;

  xsession.enable = true;
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ../shared/xmonad/xmonad.hs;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock";
  };

  services.polybar = {
    enable = true;
    script = "polybar top &";
    config = {
      "bar/top" = {
        width = "100%";
        height = "3%";
        # radius = 0;
        tray-position  = "right";
        modules-center = "date";
      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%d.%m.%y";
        time = "%H:%M";
        label = "%time%  %date%";
      };
    };
  };

  services.pasystray = {
    enable = true;
  };

  systemd.user.services.nitrogen = {
    Unit = {
      Description = "Nitrogen";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nitrogen}/bin/nitrogen --random --head=-1 --set-tiled /home/esk/Images/wallpaper";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  # i18n.inputMethod = {
  #   enabled = "fcitx5";
  #   fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  # };

  systemd.user.services.ibus = {
    Unit = {
      Description = "ibus";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${ibus}/bin/ibus-daemon --xim";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  xdg = {
    enable = true;

    userDirs = {
      enable      = true;
      desktop     = "$HOME/Desktop";
      download    = "$HOME/Downloads";
      documents   = "$HOME/Documents";
      templates   = "$HOME/Templates";
      music       = "$HOME/Music";
      videos      = "$HOME/Videos";
      pictures    = "$HOME/Pictures";
      publicShare = "$HOME/share/public";
    };

    desktopEntries = {
      # firefox-def = {
      #   name = "Firefox Default Profile";
      #   genericName = "Web Browser";
      #   # exec = "firefox -P default %U";
      #   # terminal = false;
      #   # categories = [ "Application" "Network" "WebBrowser" ];
      #   # mimeType = [
      #   #   "text/html"
      #   #   "text/xml"
      #   #   "application/xhtml+xml"
      #   #   "application/vnd.mozilla.xul+xml"
      #   #   "x-scheme-handler/http"
      #   #   "x-scheme-handler/https"
      #   #   "x-scheme-handler/ftp"
      #   # ];
      # };
    };

    mimeApps = {
      enable = true;
      associations.added = {
        "image/png"       = "feh.desktop";
        "image/jpeg"      = "feh.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
      };

      defaultApplications = {
        "text/html"                = [ "firefox-def.desktop" ];
        "x-scheme-handler/http"    = [ "firefox-def.desktop" ];
        "x-scheme-handler/https"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/about"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox-def.desktop" ];
      };
    };

  };

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
