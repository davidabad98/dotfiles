-- lua/plugins/colorizer.lua
return {
	"norcalli/nvim-colorizer.lua",
	enabled = false,
	event = { "BufReadPost", "BufNewFile" }, -- or "VeryLazy"
	config = function()
		-- Attach to certain Filetypes, add special configuration for `html`
		-- Use `background` for everything else.
		require("colorizer").setup({
			"css",
			"javascript",
			"html",
			html = {
				mode = "foreground",
			},
		})
	end,
}
