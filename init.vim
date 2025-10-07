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
set clipboard+=unnamedplus
set ruler
let mapleader = " "
set guicursor=n-v-c:block-Cursor
set guicursor+=n-v-c:blinkon0
set relativenumber

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Comment/uncomment for both normal and visual modes
nnoremap <leader>cc ^i// <Esc>    " Single line without selection
vnoremap <leader>cc :norm ^i// <CR>   " Multiple lines with selection
nnoremap <leader>uu ^xxx<Esc>     " Single line without selection
vnoremap <leader>uu :norm ^xxx<CR>    " Multiple lines with selection

" noremap <leader>tt ?^[ \t]*[^.].*=[^=]?<Esc>f=byiwostd.debug.print(\"<Esc>pviwgUa: {d}\n\", .{<Esc>pa});<Esc>/asdfjklasdf<Enter>0		" Zig; gen print statement for variable in the line above.

" Zig; gen print statement for variable in the line above.
function! s:GenZigPrint()
  " Search backwards for a line containing an assignment operator (=, not ==)
  " The pattern '\v\w+\s*=[^=]' looks for a word, optional space, then = followed by not =
  let lnum = search('\v\w+\s*=[^=]', 'bW')

  " Check if a match was found
  if lnum == 0
    echo "No variable assignment found above."
    return
  endif

  let line_content = getline(lnum)

  " Now, check if the found line is a field assignment (starts with '.')
  if line_content =~ '^\s*\.'
    echo "Found an assignment, but it's a field assignment (starts with '.'). Skipping."
    return
  endif

  " Extract the variable name using the same robust pattern.
  " '\ze' marks the end of the match, so we only get the variable name itself.
  let var = matchstr(line_content, '\v\w+\ze\s*=[^=]')

  if empty(var)
    " This is unlikely to happen if the search succeeded, but it's good practice
    echo "Could not extract variable name from line."
    return
  endif

  " Build the print statement using printf for clarity
  let print_line = printf('std.debug.print("%s: {d}\\n", .{%s});', toupper(var), var)

  " Append the new line below the cursor and indent it correctly
  call append(line('.'), print_line)
  normal! ==
endfunction

" Map the function to your leader key
noremap <leader>tt :call <SID>GenZigPrint()<CR>


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

autocmd FileType rust map <buffer> <F6> :w<CR>:exec '!cargo test -- --nocapture'<CR>
autocmd FileType rust imap <buffer> <F6> <esc>:w<CR>:exec '!cargo test -- --nocapture'<CR>
autocmd FileType rust map <buffer> <F9> :w<CR>:exec '!cargo run --release'<CR>
autocmd FileType rust imap <buffer> <F9> <esc>:w<CR>:exec '!cargo run --release'<CR>

autocmd FileType c map <buffer> <F9> :w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType c imap <buffer> <F9> <esc>:w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType cpp map <buffer> <F9> :w<CR>:exec '!make run' shellescape(@%, 1)<CR>
autocmd FileType cpp imap <buffer> <F9> <esc>:w<CR>:exec '!make run' shellescape(@%, 1)<CR>

autocmd FileType zig map <buffer> <F6> :w<CR>:exec '!zig test' shellescape(@%, 1)<CR>
autocmd FileType zig map <buffer> <F7> :w<CR>:exec '!zig build run -Doptimize=Debug'<CR>
autocmd FileType zig map <buffer> <F8> :w<CR>:exec '!zig build run -Doptimize=ReleaseSafe'<CR>
autocmd FileType zig map <buffer> <F9> :w<CR>:exec '!zig build run -Doptimize=ReleaseFast'<CR>

autocmd FileType odin map <buffer> <F9> :w<CR>:exec '!odin run .'<CR>


call plug#begin()
Plug 'jsborjesson/vim-uppercase-sql'
Plug 'morhetz/gruvbox'
Plug 'rust-lang/rust.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'ziglang/zig.vim'
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


local servers = {
	'clangd', 'pyright', 'rust_analyzer', 'zls'
}

local on_attach = function(client, bufnr)
  -- Map Ctrl+K to show hover documentation
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })
  -- Optionally, still map Shift+K if you want
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })
end


require'lspconfig'.ols.setup{
  on_attach = function(client, bufnr)
    -- client: The LSP client
    -- bufnr: The buffer number

    -- Map Ctrl+K to vim.lsp.buf.hover for Odin
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, { buffer = bufnr })
    
    -- Optional: Print a message to confirm on_attach is being called
    print("ols on_attach called for buffer: " .. bufnr)
  end,
  capabilities = {
    hover = {
      contentFormat = { 'markdown', 'plaintext' },
    },
  },
}
require'lspconfig'.clangd.setup{on_attach = on_attach}
require'lspconfig'.pyright.setup{on_attach = on_attach}
require'lspconfig'.rust_analyzer.setup{
	on_attach = function(client, bufnr)
		-- client: The LSP client
		-- bufnr: The buffer number

		-- Correctly map Shift+K to vim.lsp.buf.hover
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
		-- Or, if Shift is required in your terminal:
		-- vim.keymap.set('n', '<S-K>', vim.lsp.buf.hover, { buffer = bufnr })

		-- Optional: Print a message to confirm on_attach is being called
		print("rust-analyzer on_attach called for buffer: " .. bufnr)
	  end,
	  capabilities = {
		hover = {
		  contentFormat = { 'markdown', 'plaintext' },
		},
	  },
}
require'lspconfig'.zls.setup{
	cmd = { '/home/jakemehlman/zls/zig-out/bin/zls' },
	settings = {
		zls = {
		  -- Whether to enable build-on-save diagnostics
		  --
		  -- Further information about build-on save:
		  -- https://zigtools.org/zls/guides/build-on-save/
		  -- enable_build_on_save = true,

		  -- Neovim already provides basic syntax highlighting
		  semantic_tokens = "partial",

		  -- omit the following line if `zig` is in your PATH
	 	  zig_exe_path = "/home/jakemehlman/Downloads/zig-x86_64-linux-0.14.1/zig",
      	  zig_lib_path = "/home/jakemehlman/Downloads/zig-x86_64-linux-0.14.1/lib"
		}
	},

	on_attach = function(client, bufnr)
		-- client: The LSP client
		-- bufnr: The buffer number

		-- Correctly map Shift+K to vim.lsp.buf.hover
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
		-- Or, if Shift is required in your terminal:
		-- vim.keymap.set('n', '<S-K>', vim.lsp.buf.hover, { buffer = bufnr })

		-- Optional: Print a message to confirm on_attach is being called
		print("zls on_attach called for buffer: " .. bufnr)
	  end,
	  capabilities = {
		hover = {
		  contentFormat = { 'markdown', 'plaintext' },
		},
	  },
}
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
