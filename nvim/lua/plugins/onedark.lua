return {
	'navarasu/onedark.nvim',
	lazy = false, -- Make sure loaded during start-up.
	priority = 1000, -- Make sure loaded before all the other plugins.
	config = function()
		-- Configure the colour scheme.
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
		-- If running headless, skip setup.
		if next(vim.api.nvim_list_uis()) ~= nil then
			-- Load the colour scheme.
			require('onedark').load()
		end
	end,
}
