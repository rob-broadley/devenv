-- Load system-installed tree-sitter parsers and, per buffer, enable
-- highlighting, indent, and expression folding via a FileType autocmd.
-- Parser list (treesitter_parsers.lua) is generated at container build time by
-- nvim-gen-treesitter-parsers (see Containerfile). Neovim's language.add
-- defaults symbol_name to lang, then prepends "tree_sitter_" when loading
-- the C symbol — so p.lang = "python" finds "tree_sitter_python" by default.
local ok, parsers = pcall(require, 'treesitter_parsers')
if not ok then
	vim.schedule(function()
		vim.notify('treesitter: failed to load treesitter_parsers: ' .. tostring(parsers), vim.log.levels.ERROR)
	end)
elseif type(parsers) == 'table' then
	local reg_ok, reg_fail = 0, 0
	for _, p in ipairs(parsers) do
		local added, err = pcall(vim.treesitter.language.add, p.lang, {path = p.path})
		if added then
			reg_ok = reg_ok + 1
		else
			reg_fail = reg_fail + 1
			-- Defer notifications until after startup so that notification-override plugins
			-- (e.g. nvim-notify, noice.nvim) have had time to replace vim.notify.
			vim.schedule(function()
				vim.notify('treesitter: failed to register ' .. p.lang .. ': ' .. tostring(err), vim.log.levels.WARN)
			end)
		end
	end
	if reg_fail > 0 then
		vim.schedule(function()
			vim.notify(('treesitter: registered %d/%d parsers (%d failed)'):format(reg_ok, reg_ok + reg_fail, reg_fail), vim.log.levels.WARN)
		end)
	elseif reg_ok == 0 then
		vim.schedule(function()
			vim.notify('treesitter: registered 0 parsers — treesitter_parsers.lua may be empty or malformed', vim.log.levels.WARN)
		end)
	else
		vim.schedule(function()
			vim.notify(('treesitter: registered %d parser(s)'):format(reg_ok), vim.log.levels.INFO)
		end)
	end
else
	vim.schedule(function()
		vim.notify('treesitter: treesitter_parsers module loaded but returned ' .. type(parsers) .. ', expected table', vim.log.levels.WARN)
	end)
end

-- Native Tree-sitter: enable highlighting, indent, and expression folding when a parser is available.
local augroup = vim.api.nvim_create_augroup("treesitter", {clear = true})
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local ft = vim.bo[bufnr].filetype
		local cb_ok, cb_err = pcall(function()
			local lang = vim.treesitter.language.get_lang(ft)
			if lang then
				local started, ts_err = pcall(vim.treesitter.start, bufnr, lang)
				if started then
					vim.bo[bufnr].indentexpr = 'v:lua.vim.treesitter.indentexpr()'
					for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
						vim.wo[winid].foldmethod = 'expr'
						vim.wo[winid].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
					end
					return
				else
					vim.schedule(function()
						vim.notify('treesitter: parser available for ' .. lang .. ' but start() failed: ' .. tostring(ts_err), vim.log.levels.WARN)
					end)
				end
			end
			for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
				vim.wo[winid].foldmethod = 'manual'
			end
		end)
		if not cb_ok then
			vim.schedule(function()
				vim.notify('treesitter FileType autocmd [' .. ft .. ']: ' .. tostring(cb_err), vim.log.levels.ERROR)
			end)
		end
	end,
})
