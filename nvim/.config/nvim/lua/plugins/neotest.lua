-- lua/plugins/neotest.lua
return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"Issafalcon/neotest-dotnet",
		"nvim-neotest/neotest-python",
	},
	config = function()
		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				-- Python tests (pytest / unittest)
				require("neotest-python")({
					dap = { justMyCode = false }, -- allow stepping into libs if you like
					runner = "pytest", -- optional but often more reliable
				}),
				-- .NET tests
				require("neotest-dotnet")({
					dap = {
						-- match the adapter name we defined above
						adapter_name = "netcoredbg",
						-- you can also pass dap args here if needed
						-- args = { justMyCode = false },
					},
				}),
			},
		})

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }
		-- Run nearest test
		map("n", "<leader>tn", function()
			neotest.run.run()
		end, vim.tbl_extend("force", opts, { desc = "[T]est [N]earest" }))

		-- Run all tests in current file
		map("n", "<leader>tf", function()
			neotest.run.run(vim.fn.expand("%"))
		end, vim.tbl_extend("force", opts, { desc = "[T]est [F]ile" }))

		-- Run entire test suite
		map("n", "<leader>ta", function()
			neotest.run.run({ suite = true })
		end, vim.tbl_extend("force", opts, { desc = "[T]est [A]ll" }))

		-- Toggle summary pane
		map("n", "<leader>ts", function()
			neotest.summary.toggle()
		end, vim.tbl_extend("force", opts, { desc = "[T]est [S]ummary" }))

		-- Show output for nearest test
		map("n", "<leader>to", function()
			neotest.output.open({ enter = true })
		end, vim.tbl_extend("force", opts, { desc = "[T]est [O]utput" }))

		-- Open output panel (richer history view)
		map("n", "<leader>tO", function()
			neotest.output_panel.toggle()
		end, vim.tbl_extend("force", opts, { desc = "[T]est [O]utput panel" }))
	end,
}
