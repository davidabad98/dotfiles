-- lua/plugins/neo-tree.lua
return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	lazy = false,
	keys = {
		{ "<C-e>", "<cmd>Neotree filesystem reveal left<CR>", desc = "Neo-tree toggle/reveal" },
	},
	opts = {
		-- optional: if Neo-tree is the last window, close Neovim
		close_if_last_window = true,
		event_handlers = {
			{
				event = "file_opened",
				handler = function(_)
					-- close the tree when a file is opened
					require("neo-tree.command").execute({ action = "close" })
				end,
			},
		},
	},
}
