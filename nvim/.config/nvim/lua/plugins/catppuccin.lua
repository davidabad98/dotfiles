-- lua/plugins/catppuccin.lua
return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		transparent_background = true,
		flavour = "mocha", -- latte, frappe, macchiato, mocha

		-- IMPORTANT: enable telescope integration
		integrations = {
			telescope = { enabled = true },
			-- other integrations...
		},
		custom_highlights = function(colors)
			-- pick a slightly darker area for the prompt
			local prompt = colors.crust or colors.surface0

			return {
				-- main window
				TelescopeNormal = { bg = colors.none, fg = colors.text },

				-- remove border by making it same as bg
				TelescopeBorder = { bg = colors.none, fg = colors.base },

				-- prompt line
				TelescopePromptNormal = { bg = prompt, fg = colors.text },
				TelescopePromptBorder = { bg = prompt, fg = prompt },

				-- nice colored prompt title
				TelescopePromptTitle = { bg = colors.mauve, fg = colors.crust },

				-- hide these titles (same fg/bg)
				TelescopePreviewTitle = { bg = colors.base, fg = colors.base },
				TelescopeResultsTitle = { bg = colors.base, fg = colors.base },
			}
		end,
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
