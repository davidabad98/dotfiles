-- lua/plugins/harpoon.lua
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			-- you can tune this later
			default = {
				-- example:
				-- sync_on_ui_close = true,
			},
		})

		---------------------------------------------------------------------------
		-- Telescope-powered Harpoon picker
		---------------------------------------------------------------------------
		local conf = require("telescope.config").values
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")

		local function harpoon_list()
			return harpoon:list()
		end

		local function toggle_telescope(harpoon_files)
			local file_paths = {}

			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			pickers
				.new({}, {
					prompt_title = "Harpoon",
					finder = finders.new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		---------------------------------------------------------------------------
		-- Keymaps
		---------------------------------------------------------------------------
		local map = vim.keymap.set

		-- Core actions: add / remove / show list (Telescope UI)
		map("n", "<leader>ha", function()
			harpoon_list():add()
		end, { desc = "[H]arpoon [A]dd file" })

		map("n", "<leader>hr", function()
			harpoon_list():remove()
		end, { desc = "[H]arpoon [R]emove file" })

		-- Telescope-based Harpoon UI
		map("n", "<leader>hh", function()
			toggle_telescope(harpoon_list())
		end, { desc = "[H]arpoon [H]op to file (Telescope)" })

		-- Harpoon UI
		vim.keymap.set("n", "<C-t>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		-- Quick navigation between pinned files
		map("n", "<leader>1", function()
			harpoon_list():select(1)
		end, { desc = "Harpoon to file 1" })

		map("n", "<leader>2", function()
			harpoon_list():select(2)
		end, { desc = "Harpoon to file 2" })

		map("n", "<leader>3", function()
			harpoon_list():select(3)
		end, { desc = "Harpoon to file 3" })

		map("n", "<leader>4", function()
			harpoon_list():select(4)
		end, { desc = "Harpoon to file 4" })
	end,
}
