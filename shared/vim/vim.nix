# home-manager module to configure neovim
{ pkgs, ... }:

let
  skkDict = pkgs.fetchurl {
    url = "https://github.com/skk-dev/dict/raw/b798a46b886f71c0c25ad2a9e78b1c3e8933970c/SKK-JISYO.L";
    sha256 = "sha256-6Jb8ReQYWgvGIWz05L5BXLwBKBcdPsQryWxvWPehDyQ=";
  };
in
{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withNodeJs = true;
    package = pkgs.neovim-unwrapped;
    plugins = with pkgs.vimPlugins; [
      ({
        plugin = vim-airline;
        # Put extra config here so it's earlier than other plugin config
        config = ''
          source ${./vimrc}

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
        config =
          ''
            imap <C-j> <Plug>(skkeleton-toggle)
            cmap <C-j> <Plug>(skkeleton-toggle)
            tmap <C-j> <Plug>(skkeleton-toggle)

            function! s:skkeleton_init() abort
            call skkeleton#config({
              \ 'eggLikeNewline': v:true,
              \ 'globalDictionaries': ["''
          + "${skkDict}"
          + ''
            "],
                        \ })
                      endfunction
                      augroup skkeleton-initialize-pre
                        autocmd!
                        autocmd User skkeleton-initialize-pre call s:skkeleton_init()
                      augroup END
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
      ddc-source-lsp
      ddc-ui-pum
      ({
        plugin = ddc-vim;
        # TODO
        config = ''
          set completeopt=menuone,noinsert,noselect
          set shortmess+=c
          call ddc#custom#patch_global('ui', 'pum')
          call ddc#custom#patch_global('sources', ['lsp', 'skkeleton'])
          call ddc#custom#patch_global('sourceOptions', #{
            \   _: #{
            \     matchers: ['matcher_head'],
            \   },
            \   lsp: #{
            \     mark: 'lsp',
            \     forceCompletionPattern: '\.\w*|:\w*|->\w*',
            \   },
            \   skkeleton: #{
            \     mark: 'skk',
            \     matchers: [],
            \     sorters: [],
            \     isVolatile: v:true,
            \     minAutoCompleteLength: 1,
            \   },
            \ })

          call ddc#custom#patch_global('sourceParams', #{
            \   lsp: #{
            \     snippetEngine: denops#callback#register({
            \           body -> vsnip#anonymous(body)
            \     }),
            \     enableResolveItem: v:true,
            \     enableAdditionalTextEdit: v:true,
            \   }
            \ })

          " <TAB>: completion.
          inoremap <silent><expr> <TAB>
            \ pumvisible() ? '<C-n>' :
            \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
            \ '<TAB>' : ddc#map#manual_complete()

          " <S-TAB>: completion back.
          inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
          inoremap <C-n>   <Cmd>call pum#map#select_relative(+1)<CR>
          inoremap <C-p>   <Cmd>call pum#map#select_relative(-1)<CR>

          " Diagnostics helpers
          nnoremap <silent> <Leader>d :lua vim.diagnostic.open_float()<CR>
          nnoremap <silent> <Leader>ld :lua vim.diagnostic.setloclist()<CR>

          call ddc#enable()
        '';
      })
      vim-nickel
      vim-nix
      ({
        plugin = vim-colorschemes;
        config = ''
          colorscheme inkpot
          " fixes my colors for some reason, ideally we shouldn't need this
          set notermguicolors
        '';
      })
      # Used in nvim-lspconfig below
      rust-tools-nvim
      ({
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          vim.lsp.inlay_hint.enable()

          local configs = require'lspconfig'

          local capabilities = require("ddc_source_lsp").make_client_capabilities()
          configs.denols.setup({
            capabilities = capabilities,
          })

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
          let g:go_fmt_command="gopls"
          let g:go_gopls_gofumpt = 1
          let g:go_highlight_functions = 1
          let g:go_highlight_methods = 1
          let g:go_highlight_structs = 1
          let g:go_highlight_operators = 1
          let g:go_highlight_build_constraints = 1
          let g:go_imports_mode = 'gopls'
          let g:go_metalinter_autosave_enabled = []
          let g:go_metalinter_enabled = []

          " Borrowed from vim-go #3023
          let g:go_gopls_local = {'/home/esk/dev/ngrok/go': 'go.ngrok.com'}
        '';
      })
      ({
        plugin = ale;
        config = ''
          let g:ale_go_golangci_lint_package = 1
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
}
