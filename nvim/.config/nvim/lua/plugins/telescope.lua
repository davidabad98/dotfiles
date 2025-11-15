-- lua/plugins/telescope.lua
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },

		-- Use opts so lazy.nvim merges/handles setup for us
		opts = {
			defaults = {
				-- horizontal, prompt on top
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						-- padding = 0 => use full screen size
						width = { padding = 0 },
						height = { padding = 0 },
						preview_width = 0.5,
					},
				},
				sorting_strategy = "ascending",

				-- filename-first path display
				-- path_display = { "filename_first" },
			},
			-- stick ui-select config here so we call setup only once
			extensions = {
				["ui-select"] = require("telescope.themes").get_dropdown({}),
			},
		},

		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)

			-- load ui-select extension (the second spec just needs this)
			pcall(telescope.load_extension, "ui-select")

			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Telescope Find files" })
			vim.keymap.set("n", "<leader>ff", builtin.git_files, { desc = "Telescope Find Git files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope Help" })
		end,
	},

	-- Just responsible for loading the extension; config is in main telescope opts
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").load_extension("ui-select")
		end,
	},
}
