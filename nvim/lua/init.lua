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

-- Set up plugin manager.
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
local opts = {
	performance = {
		rtp = {
			-- Do not reset the runtime path.
			-- This is so other lua config files can be loaded after the plugins.
			reset = false,
		},
	},
}
-- Load / Configure plugins.
require("lazy").setup("plugins", opts)

-- Completion
-- Autocomplete with dictionary words when spell check is on.
vim.opt.complete:append("kspell")
-- Map Ctrl+s to word suggestions.
vim.keymap.set("i", "<C-s>", "<C-x><C-k>", {noremap = true, silent = true})
-- Commenting
-- Make Ctrl+/ comment line or selection.
vim.keymap.set("v", "<C-_>", ":Commentary<cr>", {noremap = true})
vim.keymap.set("n", "<C-_>", ":Commentary<cr>", {noremap = true})
