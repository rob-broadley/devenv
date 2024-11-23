lua <<EOF
-- Basic Config
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.breakindent = true
vim.opt.showbreak = "->"
vim.opt.expandtab = true
vim.opt.spell = true
vim.opt.spelllang = "en_gb"
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Leave insert mode when focus lost.
vim.api.nvim_create_autocmd(
	{"FocusLost", "TabLeave"},
	{command = "stopinsert"}
)

-- End configuration here if running as privileged / system user.
if tonumber(vim.fn.expand("$EUID")) < 1000 then
	return
end

-- Set location of system Python.
-- Otherwise pynvim needs to be installed in every venv.
vim.g.python_host_prog = "/usr/bin/python3"
vim.g.python3_host_prog = "/usr/bin/python3"

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
	"dense-analysis/ale",
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

-- Completion
-- Autocomplete with dictionary words when spell check is on.
vim.opt.complete:append("kspell")
-- Map Ctrl+s to word suggestions.
vim.keymap.set("i", "<C-s>", "<C-x><C-k>", {noremap = true, silent = true})
-- Map enter to except suggestion.
vim.keymap.set(
	"i",
	"<cr>",
	[[coc#pum#visible() ? coc#_select_confirm() : "\<CR>"]],
	{expr = true, noremap = true}
)

-- Commenting
-- Make Ctrl+/ comment line or selection.
vim.keymap.set("v", "<C-_>", ":Commentary<cr>", {noremap = true})
vim.keymap.set("n", "<C-_>", ":Commentary<cr>", {noremap = true})

-- Linting, completion and auto-format.
-- Disable python linters (using coc-pyright instead).
vim.g.ale_linters = {python = {}}
-- Set fixers.
vim.g.ale_fixers = {
	['*'] = {'remove_trailing_lines', 'trim_whitespace'},
	python = {'black', 'ruff'}
}
-- Set ruff to only fix import sorting not other auto-fixes
-- (note ruff_format not enabled).
--local python_ruff_fixer = vim.api.nvim_create_augroup("PythonRuffFixer", { clear = true })
vim.api.nvim_create_autocmd(
	{"User"},
	{
    pattern = "ALEFixPre",
    group = python_ruff_fixer,
    callback = function() vim.g.ale_python_ruff_options = '--select=I' end,
	}
)
vim.api.nvim_create_autocmd(
	{"User"},
	{
    pattern = "ALEFixPost",
    group = python_ruff_fixer,
    callback = function() vim.g.ale_python_ruff_options = '' end ,
	}
)
-- Set when to lint.
vim.g.ale_lint_on_insert_leave = 1
vim.g.ale_lint_on_text_changed = 0
vim.g.ale_completion_enabled = 1
-- Disable ALE language server features.
vim.g.ale_disable_lsp = 1
-- Set up completion menu.
vim.opt.completeopt = {"menu", "menuone", "preview", "noselect", "noinsert"}
-- Use K to show documentation in preview window.
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
vim.keymap.set("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
-- Show code action menu.
vim.keymap.set("n", "ca", "<Plug>(coc-codeaction-line)", {silent = true})
-- Go to definition and references.
vim.keymap.set("n", "gd", "<Plug>(coc-definition)", {silent = true})
vim.keymap.set("n", "gr", "<Plug>(coc-references)", {silent = true})
-- Go to issues.
vim.keymap.set("n", "]l", "<Plug>(coc-diagnostic-next)", {silent = true})
vim.keymap.set("n", "[l", "<Plug>(coc-diagnostic-prev)", {silent = true})
-- Rename with F2.
vim.keymap.set("n", "<F2>", "<Plug>(coc-rename)")
-- Auto-format with leader f.
vim.keymap.set("n", "<Leader>f", "<Plug>(ale_fix)")

-- Python Setup.
vim.g.python_highlight_all = 1

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
