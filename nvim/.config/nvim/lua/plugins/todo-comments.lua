-- lua/plugins/todo-comments.lua
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },

	-- Optional, but makes the plugin lazy-load on these commands
	cmd = { "TodoQuickFix", "TodoTelescope" },

	-- Keymaps
	keys = {
		{
			"<leader>tq",
			"<cmd>TodoQuickFix<CR>",
			desc = "Todo (QuickFix list)",
		},
		{
			"<leader>tt",
			"<cmd>TodoTelescope<CR>",
			desc = "Todo (Telescope)",
		},
	},

	opts = {
		-- your configuration here (or leave empty to use defaults)
	},
}
