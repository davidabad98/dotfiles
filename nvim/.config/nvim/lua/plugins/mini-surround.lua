-- lua/plugins/mini-surround.lua
return {
	"nvim-mini/mini.surround",
	version = "*", -- use latest stable
	event = "VeryLazy", -- optional, but keeps startup fast
	config = function()
		require("mini.surround").setup({
			-- You can tweak this, but the defaults are already good
			mappings = {
				add = "sa", -- Add surrounding
				delete = "sd", -- Delete surrounding
				replace = "sr", -- Replace surrounding
				find = "sf", -- Find right surrounding
				find_left = "sF", -- Find left surrounding
				highlight = "sh", -- Highlight surrounding
				update_n_lines = "sn", -- Update search range
			},

			-- How many lines to look around for surrounding
			n_lines = 50,
		})
	end,
}
