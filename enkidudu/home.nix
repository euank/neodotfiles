{ config, pkgs, ... }:

let
  # nixatom = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/b8988e13be291029c72b76549d70c783856f2dc3.tar.gz") {};
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH =
      "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig:${pkgs.sqlite.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig:${pkgs.pam}/lib/pkgconfig:${pkgs.elfutils.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";

    COWPATH = "${pkgs.cowsay}/share/cows:${pkgs.tewisay}/share/tewisay/cows";

    GLFW_SO_PATH = "${pkgs.glfw3}/lib/libglfw.so";
    OPENAL_SO_PATH = "${pkgs.openal}/lib/libopenal.so";
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
  imports = [
    ../shared/desktop-home.nix
  ];

  home.packages = with pkgs; [
    aegisub
    desmume
    jetbrains.idea-community
    melonDS
    minecraft
    mkvtoolnix
    muttoauth2
    neomutt
    prismlauncher
    thedesk
    tor-browser-bundle-bin
    yacreader
    zoom-us
  ];

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
      ({
        plugin = denops-vim;
        # Default + no-lock https://github.com/vim-denops/denops.vim/blob/448f84ce91a573a6ce0b74044df986f6ab6dd906/doc/denops.txt#L120
        config = ''
          let g:denops#server#deno_args = ['--no-lock', '-q', '--no-check', '--unstable', '-A']
        '';
      })
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
      ddc-ui-native
      ddc-sorter_rank
      ddc-matcher_head
      ddc-source-nvim-lsp
      ddc-ui-pum
      ({
        plugin = ddc-vim;
        # TODO
        config = ''
          set completeopt=menuone,noinsert,noselect
          set shortmess+=c
          call ddc#custom#patch_global('ui', 'pum')
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

          " <TAB>: completion.
          inoremap <silent><expr> <TAB>
          \ pumvisible() ? '<C-n>' :
          \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
          \ '<TAB>' : ddc#map#manual_complete()

          " <S-TAB>: completion back.
          inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

          call ddc#enable()
        '';
      })
      vim-nickel
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
          configs.nickel_ls.setup{}

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

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
  };

  services.blueman-applet.enable = true;
  services.dropbox.enable = true;

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

  xdg = {
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
      defaultApplications = {
        "text/html"                = [ "firefox-def.desktop" ];
        "x-scheme-handler/http"    = [ "firefox-def.desktop" ];
        "x-scheme-handler/https"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/about"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox-def.desktop" ];
      };
    };
  };
}
