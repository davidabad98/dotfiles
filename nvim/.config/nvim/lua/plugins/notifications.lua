-- lua/plugins/nvim-notify.lua
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- optional:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   if not available, we use `mini` as the fallback
		{
			"rcarriga/nvim-notify",
			opts = {
				-- solid bg used for full transparency math in notify popups
				background_colour = "#000000",
			},
			-- optional: make `vim.notify(...)` use nvim-notify everywhere
			init = function()
				local ok, notify = pcall(require, "notify")
				if ok then
					vim.notify = notify
				end
			end,
		},
	},
}
