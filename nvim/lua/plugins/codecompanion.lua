return {
	'olimorris/codecompanion.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
		-- The following are optional:
		{'MeanderingProgrammer/render-markdown.nvim', ft = {'codecompanion'}},
	},
	config = true,
}
