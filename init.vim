syntax on
syntax enable
filetype plugin indent on


set number
set termguicolors
set autoindent
set autowrite
set shiftwidth=4
set tabstop=4
set smartindent
set background=dark
set t_Co=256
set fileformat=unix
set clipboard=unnamedplus
set ruler
let mapleader = " "
set guicursor=n-v-c:block-Cursor
set guicursor+=n-v-c:blinkon0

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Comment/uncomment for both normal and visual modes
nnoremap <leader>cc ^i// <Esc>    " Single line without selection
vnoremap <leader>cc :norm ^i// <CR>   " Multiple lines with selection
nnoremap <leader>uu ^xxx<Esc>     " Single line without selection
vnoremap <leader>uu :norm ^xxx<CR>    " Multiple lines with selection

function! FormatFunctionLine()
    let l:line = getline(".")
    if l:line =~ '^\s*\(.*\)(.*) {$'
        let l:args = matchlist(l:line, '^\s*\(.*\)(\(.*\)) {')[2]
        let l:argsList = split(l:args, ',\s\+')
        let l:newLine = substitute(l:line, '('.l:args.')', "(\n\t\t" . join(l:argsList, ",\n\t\t") . "\n\t\t)", "")
        call setline(".", l:newLine)
    endif
endfunction

nnoremap <leader>jj :call FormatFunctionLine()<CR>

autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python' shellescape(@%, 1)<CR>

autocmd FileType rust map <buffer> <F9> :w<CR>:exec '!cargo run --release' shellescape(@%, 1)<CR>
autocmd FileType rust imap <buffer> <F9> <esc>:w<CR>:exec '!cargo run --release' shellescape(@%, 1)<CR>

autocmd FileType c map <buffer> <F9> :w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType c imap <buffer> <F9> <esc>:w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType cpp map <buffer> <F9> :w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType cpp imap <buffer> <F9> <esc>:w<CR>:exec '!make run' shellescape(@%, 1)<CR>

autocmd FileType zig map <buffer> <F6> :w<CR>:exec '!zig test' shellescape(@%, 1)<CR>
autocmd FileType zig map <buffer> <F7> :w<CR>:exec '!zig build run -Doptimize=Debug'<CR>
autocmd FileType zig map <buffer> <F8> :w<CR>:exec '!zig build run -Doptimize=ReleaseSafe'<CR>
autocmd FileType zig map <buffer> <F9> :w<CR>:exec '!zig build run -Doptimize=ReleaseFast'<CR>


call plug#begin()
Plug 'jsborjesson/vim-uppercase-sql'
Plug 'morhetz/gruvbox'
Plug 'rust-lang/rust.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
call plug#end()

colorscheme gruvbox

let g:LanguageClient_serverCommands = {
\ 'rust': ['rust-analyzer'],
\ }

lua <<EOF
require'nvim-treesitter.configs'.setup {
	ensure_installed = {"c", "cpp", "python"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  	highlight = {
		enable = true,              -- false will disable the whole extension
		disable = {},  				-- list of language that will be disabled
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
  },
}
require("mason").setup()

local servers = {'clangd', 'pyright', 'rust_analyzer', 'zls'}
require'lspconfig'.clangd.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.rust_analyzer.setup{}
require'lspconfig'.zls.setup{}

EOF

let g:zig_fmt_save 	   = 0
let g:zig_fmt_autosave = 0

set completeopt=menu,menuone,noselect

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-enter>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['clangd'].setup {
    capabilities = capabilities
  }
EOF

let g:clangd_args = ['--compile-commands=%:p:h/compile_commands.json']
