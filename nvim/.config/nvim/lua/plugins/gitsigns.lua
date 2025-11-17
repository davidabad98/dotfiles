-- lua/plugins/gitsigns.lua
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- load only when editing a file
	config = function()
		local gitsigns = require("gitsigns")

		gitsigns.setup({
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`

			-- Attach buffer-local keymaps
			on_attach = function(bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(gitsigns.next_hunk)
					return "<Ignore>"
				end, "Next hunk")

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(gitsigns.prev_hunk)
					return "<Ignore>"
				end, "Prev hunk")

				-- Actions
				map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
				map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
				map("v", "<leader>hs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage hunk (visual)")
				map("v", "<leader>hr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset hunk (visual)")

				map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
				map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
				map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")

				map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
				map("n", "<leader>hb", function()
					gitsigns.blame_line({ full = true })
				end, "Blame line (full)")
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle line blame")
				map("n", "<leader>td", gitsigns.toggle_deleted, "Toggle show deleted")

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
			end,
		})
	end,
}
