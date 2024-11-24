return {
	'nvim-lualine/lualine.nvim',
	lazy = false, -- Make sure loaded during start-up.
	config = function()
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
							-- Limit branch to 20 chars, unless diff mode, then 30.
							local max = 20
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
	end,
}
