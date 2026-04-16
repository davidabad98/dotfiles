-- lua/plugins/diffview.lua
return {
	"sindrets/diffview.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	lazy = false, -- must be eager: mergetool calls `nvim -c "DiffviewOpen"` before VeryLazy fires
	config = function()
		local diffview = require("diffview")

		-- Highlight groups for conflict markers in the RESULT buffer.
		-- Defined here so they are available when diff_buf_read fires.
		-- Green = ours (HEAD), yellow = separator, blue = theirs (incoming).
		vim.api.nvim_set_hl(0, "ConflictMarkerOurs", { bg = "#2d4a2d", fg = "#89d988", bold = true })
		vim.api.nvim_set_hl(0, "ConflictMarkerSep", { bg = "#4a4a2d", fg = "#d9d988", bold = true })
		vim.api.nvim_set_hl(0, "ConflictMarkerTheirs", { bg = "#2d2d4a", fg = "#8888d9", bold = true })

		diffview.setup({
			enhanced_diff_hl = true, -- better diff highlighting
			use_icons = true, -- assumes you already have nvim-web-devicons
			view = {
				-- Merge tool layout: OURS (HEAD) | THEIRS on top, RESULT (editable) on bottom.
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true, -- avoid noise while resolving conflicts
					winbar_info = true, -- shows LOCAL / BASE / REMOTE labels in winbar
				},
			},
			hooks = {
				diff_buf_read = function(_)
					-- Highlight conflict marker lines in whichever buffer has them.
					-- Safe to apply to all diff buffers: the patterns only match in
					-- the RESULT (working tree) buffer, so reference panes are unaffected.
					vim.fn.matchadd("ConflictMarkerOurs", [[^<<<<<<<.*]], 20)
					vim.fn.matchadd("ConflictMarkerSep", [[^=======.*]], 20)
					vim.fn.matchadd("ConflictMarkerTheirs", [[^>>>>>>>.*]], 20)
				end,
			},
		})

		-- Global keymap helper (similar style to your gitsigns setup)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, desc = desc })
		end

		-------------------------------------------------------------------------
		-- Core views
		-------------------------------------------------------------------------

		-- Open a diff view for all changes vs index (unstaged + staged)
		-- :DiffviewOpen with no args compares working tree vs index. :contentReference[oaicite:1]{index=1}
		map("n", "<leader>gvo", "<cmd>DiffviewOpen<CR>", "Diffview: open (vs index)")

		-- Optional: open against a specific revision (edit the rev on the command-line)
		-- This just drops you into the cmdline with :DiffviewOpen prefilled.
		map("n", "<leader>gvO", ":DiffviewOpen ", "Diffview: open (custom rev)")

		-- Close current diffview tab
		map("n", "<leader>gvc", "<cmd>DiffviewClose<CR>", "Diffview: close")

		-- Refresh stats & file list for the current Diffview :contentReference[oaicite:2]{index=2}
		map("n", "<leader>gvR", "<cmd>DiffviewRefresh<CR>", "Diffview: refresh")

		-------------------------------------------------------------------------
		-- File history views
		-------------------------------------------------------------------------
		-- History for *current file* (with diffs)
		-- :DiffviewFileHistory % :contentReference[oaicite:3]{index=3}
		map("n", "<leader>gvf", "<cmd>DiffviewFileHistory %<CR>", "Diffview: file history (current file)")

		-- History for the *current branch / project* (all files) :contentReference[oaicite:4]{index=4}
		map("n", "<leader>gvF", "<cmd>DiffviewFileHistory<CR>", "Diffview: file history (branch)")

		-- History for visual selection’s line range in current file (really handy for blame-style digging) :contentReference[oaicite:5]{index=5}
		map("v", "<leader>gvf", ":'<,'>DiffviewFileHistory<CR>", "Diffview: history for selection")

		-------------------------------------------------------------------------
		-- File panel / focus helpers
		-------------------------------------------------------------------------
		-- Toggle file list panel in current Diffview :contentReference[oaicite:6]{index=6}
		map("n", "<leader>gvt", "<cmd>DiffviewToggleFiles<CR>", "Diffview: toggle file panel")

		-- Focus file panel (when it’s visible)
		map("n", "<leader>gvp", "<cmd>DiffviewFocusFiles<CR>", "Diffview: focus file panel")

		-------------------------------------------------------------------------
		-- Bonus: quick “last commit vs working tree” helper (optional)
		-------------------------------------------------------------------------
		-- Compare current working tree against HEAD (edit this if you prefer another base).
		-- From docs: :DiffviewOpen [git rev] compares against that revision. :contentReference[oaicite:7]{index=7}
		map("n", "<leader>gvh", "<cmd>DiffviewOpen HEAD<CR>", "Diffview: changes since HEAD (current file changes)")
	end,
}
