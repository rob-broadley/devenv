return {
	'wookayin/semshi',
	build = ':UpdateRemotePlugins',
	priority = 100  -- Load before other syntax highlighters (e.g. treesitter).
}
