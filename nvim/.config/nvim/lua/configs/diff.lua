-- lua/configs/diff.lua
-- Pick a file from ~/dev with Telescope and open it in a vertical diffsplit
--
-- Diff navigation reference (built-in vim motions):
--   ]c            jump to next hunk
--   [c            jump to previous hunk
--   do            obtain — pull change from other window into current
--   dp            put   — push change from current window to other
--   :diffupdate   refresh diff highlighting (useful after external changes)
--   :diffoff      turn off diff mode in current window
--   zo / zc       open / close folds in diff view

local function pick_and_diff()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("Telescope is not available", vim.log.levels.ERROR)
		return
	end

	local dev_dir = vim.fn.expand("~/dev")

	-- Verify the directory exists
	if vim.fn.isdirectory(dev_dir) == 0 then
		vim.notify("~/dev directory not found", vim.log.levels.ERROR)
		return
	end

	builtin.find_files({
		prompt_title = "Diff against...",
		cwd = dev_dir,

		-- fd: fast parallel Rust-based search, respects .gitignore, handles deep trees
		-- Falls back to telescope's built-in finder if fd is not in $PATH
		find_command = vim.fn.executable("fd") == 1
			and { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
			or nil,

		attach_mappings = function(prompt_bufnr, _)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			-- Override <CR> to open a vertical diffsplit instead of a normal edit
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if not selection then
					return
				end

				-- selection[1] is the path relative to cwd
				local selected_path = dev_dir .. "/" .. selection[1]
				vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(selected_path))
			end)

			return true -- keep all other default mappings (movement, preview, etc.)
		end,
	})
end

vim.keymap.set("n", "<leader>fc", pick_and_diff, {
	noremap = true,
	silent = true,
	desc = "Diff current file against a file picked from ~/dev",
})
