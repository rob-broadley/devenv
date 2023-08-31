" Get XDG_CONFIG_HOME or set to default if it doesn't exist
let xdg_config_home = fnamemodify(
	\ exists("$XDG_CONFIG_HOME") ? $XDG_CONFIG_HOME : '~/.config',
	\ ':p'
\)

" Disable ALE language server features
let g:ale_disable_lsp = 1

" Set up dein (plugins)
let dein_dir = fnamemodify(xdg_config_home.'nvim/dein', ':p')
"dein Scripts-----------------------------
if &compatible
	set nocompatible							 " Be iMproved
endif

" Required:
let &runtimepath.=','.escape(dein_dir.'repos/github.com/Shougo/dein.vim', '\,')

" Required:
if dein#load_state(dein_dir)
	call dein#begin(dein_dir)

	" Let dein manage dein
	" Required:
	call dein#add(dein_dir . 'repos/github.com/Shougo/dein.vim')

	" Visual
	call dein#add('navarasu/onedark.nvim')
	call dein#add('nvim-lualine/lualine.nvim')
	call dein#add('nvim-treesitter/nvim-treesitter', {'hook_post_update': 'TSUpdate'})
	call dein#add('sheerun/vim-polyglot')
	" Editor Config
	call dein#add('editorconfig/editorconfig-vim')
	" Linting and completion and auto-format
	call dein#add('w0rp/ale')
	call dein#add('neoclide/coc.nvim', {'merged': 0, 'rev': 'release'})
	" VCS
	call dein#add('lewis6991/gitsigns.nvim')
	call dein#add('tpope/vim-fugitive')
	" Commenting
	call dein#add('tpope/vim-commentary')
	" For Python
	call dein#add('wookayin/semshi')
	" For Pandoc / Markdown
	call dein#add('vim-pandoc/vim-pandoc')
	call dein#add('vim-pandoc/vim-pandoc-syntax')
	" For keybinding help.
	call dein#add('folke/which-key.nvim')

	" Required:
	call dein#end()
	call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" Install missing plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------


" Basic Config
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

" Leave inset mode when focus lost
autocmd FocusLost,TabLeave * stopinsert

" Light the Scroll Lock LED when in insert mode
augroup ScrollLockLED
	autocmd!
	autocmd InsertEnter * :silent !xset  led named 'Scroll Lock'
	autocmd InsertLeave * :silent !xset -led named 'Scroll Lock'
	autocmd VimLeave		* :silent !xset -led named 'Scroll Lock'
augroup END


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


" Linting, completion and auto-format
let g:ale_linters = {'python': []}  " Disable python linters (using coc-pyright instead)
let g:ale_fixers = {
	\	'*': ['remove_trailing_lines', 'trim_whitespace'],
	\ 'python': ['black', 'isort'],
\}
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 0
let g:ale_completion_enabled = 1
set completeopt=menu,menuone,preview,noselect,noinsert
" Functions
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


" Python Setup
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
