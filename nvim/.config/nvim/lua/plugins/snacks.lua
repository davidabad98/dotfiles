-- lua/plugins/snacks.lua
--
-- Minimal snacks.nvim install: only `input` and `picker` are enabled.
-- Everything else in the snacks suite is explicitly left off.
-- The sole purpose is to enhance opencode.nvim's ask() and select() UX.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- Enhanced vim.ui.input — used by opencode.nvim's ask()
		input = { enabled = true },
		-- Enhanced vim.ui.select — used by opencode.nvim's select()
		picker = { enabled = true },
	},
}
