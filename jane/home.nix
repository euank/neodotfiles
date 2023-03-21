{ config, pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    COWPATH = "${pkgs.cowsay}/share/cows:${pkgs.tewisay}/share/tewisay/cows";
  };
in
{

  imports = [
    ../shared/home.nix
  ];

  home.packages = with pkgs; [
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
      ddc-ui-native
      ddc-filter-sorter_rank
      ddc-filter-matcher_head
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
