" Basic Config.
set guioptions=M
set mouse=a
set number
set breakindent
set showbreak=->
set expandtab
" Toggle paste mode.
set pastetoggle=<Leader>p
" Use tabs for make files
autocmd FileType make setlocal noexpandtab
" Spelling
set spell spelllang=en_gb
" Split directions
set splitright
set splitbelow

" Leave inset mode when focus lost.
autocmd FocusLost,TabLeave * stopinsert

" Light the Scroll Lock LED when in insert mode.
augroup ScrollLockLED
	autocmd!
	autocmd InsertEnter * :silent !xset  led named 'Scroll Lock'
	autocmd InsertLeave * :silent !xset -led named 'Scroll Lock'
	autocmd VimLeave		* :silent !xset -led named 'Scroll Lock'
augroup END


" End configuration here if running as root (uid 0).
if expand('$UID') == 0
  :finish
endif


lua <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Visual.
	"navarasu/onedark.nvim",
	"nvim-lualine/lualine.nvim",
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	"sheerun/vim-polyglot",
	-- Editor Config.
	"editorconfig/editorconfig-vim",
	-- Linting and completion and auto-format.
	"w0rp/ale",
	{"neoclide/coc.nvim", branch = "release"},
	-- VCS.
	"lewis6991/gitsigns.nvim",
	"tpope/vim-fugitive",
	-- Commenting.
	"tpope/vim-commentary",
	-- For Python.
	{"wookayin/semshi", build = ":UpdateRemotePlugins"},
	-- For Pandoc / Markdown.
	"vim-pandoc/vim-pandoc",
	"vim-pandoc/vim-pandoc-syntax",
	-- For keybinding help.
	"folke/which-key.nvim",
	-- coc extensions.
	{"fannheyward/coc-pyright", build = "npm ci"},
	-- {"neoclide/coc-json", build = "npm ci"},
})

EOF
" End of lua block.


" Completion
" Autocomplete with dictionary words when spell check is on.
set complete+=kspell
" Map Ctrl+s to word suggestions.
inoremap <silent> <C-s> <C-x><C-k>
" Map enter to except suggestion.
inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"


" Commenting (Make Ctrl+/ comment line or selection)
vnoremap <C-_> :Commentary<cr>
nnoremap <C-_> :Commentary<cr>


" Linting, completion and auto-format.
let g:ale_linters = {'python': []}  " Disable python linters (using coc-pyright instead)
let g:ale_fixers = {
	\	'*': ['remove_trailing_lines', 'trim_whitespace'],
	\ 'python': ['black', 'isort'],
\}
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 0
let g:ale_completion_enabled = 1
" Disable ALE language server features.
let g:ale_disable_lsp = 1
" Set up completion menu.
set completeopt=menu,menuone,preview,noselect,noinsert

" Functions.
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . ' ' . expand('<cword>')
  endif
endfunction

" Key bindings.
" Show code action menu.
nmap <silent> ca <Plug>(coc-codeaction-line)
" Go to definition and references.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
" Go to issues.
nmap <silent> ]l <Plug>(coc-diagnostic-next)
nmap <silent> [l <Plug>(coc-diagnostic-prev)

" Rename with F2.
nmap <F2> <Plug>(coc-rename)
" Auto-format with leader f.
nmap <Leader>f <Plug>(ale_fix)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>


" Python Setup.
let g:python_highlight_all = 1


lua <<EOF

-- If running headless, skip setup.
if next(vim.api.nvim_list_uis()) == nil then
	return
end

-- Theme.
require('onedark').setup {
	style = 'warmer',
	transparent = true,
	code_style = {
		comments = 'none',
	},
	highlights = {
		DiffAdd = {bg = '#273327'},
		DiffChange = {bg = '#262733'},
		DiffDelete = {bg = '#332727'},
		DiffText = {bg = '#3a3b4c'},
		SpellBad = {fg = '$red'},
		TODO = {fg = '$orange', fmt = 'bold'},
	},
}
require('onedark').load()

-- Status Line.
require('lualine').setup {
	options = {
		theme = 'onedark',
	},
	sections = {
		lualine_b = {
			{
				'branch',
				fmt = function(str)
					-- Remove branch prefix (any letters up to and including 1st '/').
					str = str:gsub('^%a+%/', '')
					-- Limit branch to 10 chars, unless diff mode, then 30.
          local max = 10
					if vim.api.nvim_win_get_option(0, 'diff') then
						max = 30
          end
          return str:sub(0, max)
				end
			},
      'diff',
      'diagnostics',
		},
	},
}

-- Improved syntax highlighting.
require('nvim-treesitter.configs').setup {
	highlight = {
		enable = true,
	},
  indent = {
		enable = true,
	},
}

-- Git decorations.
require('gitsigns').setup {}

-- Keybinding help.
local wk = require('which-key')
wk.register(mappings, opts)

EOF
" End of lua block.
