-- lua/configs/diff.lua
--
-- Diff navigation reference (built-in vim motions):
--   ]c            jump to next hunk
--   [c            jump to previous hunk
--   do            obtain — pull change from other window into current
--   dp            put   — push change from current window to other
--   :diffupdate   refresh diff highlighting (useful after external changes)
--   :diffoff      turn off diff mode in current window
--   zo / zc       open / close folds in diff view

-----------------------------------------------------------
-- Pick a file from ~/dev with Telescope and open it in a vertical diffsplit
-----------------------------------------------------------
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

		-- Let Telescope show hidden files too (dotfiles)
		hidden = true,

		-- If your .env.example is ignored by .gitignore/.ignore, enable this.
		-- You can remove if you still want ignore rules respected.
		no_ignore = true,

		-- fd: include hidden, optionally include ignored, and exclude .git directory
		find_command = vim.fn.executable("fd") == 1 and {
			"fd",
			"--type",
			"f",
			"--hidden",
			"--no-ignore", -- comment this out if you DON'T want ignored files
			"--exclude",
			".git",
		} or nil,

		attach_mappings = function(prompt_bufnr, _)
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if not selection then
					return
				end

				-- Prefer selection.path when available; fallback to [1]
				local selected_path = selection.path or selection[1]
				if not selected_path then
					return
				end

				vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(selected_path))
			end)

			return true
		end,
	})
end

vim.keymap.set("n", "<leader>fc", pick_and_diff, {
	noremap = true,
	silent = true,
	desc = "Diff current file against a file picked from ~/dev",
})

-----------------------------------------------------------
-- Context-aware diff arrows (Left/Right swap do/dp depending on which diff window you're in)
-----------------------------------------------------------
local function diff_is_left_window()
	-- diffpos looks like: "left", "right", sometimes includes other tokens depending on version/config.
	-- We treat "left" as left window, everything else as right-ish.
	local pos = vim.fn.win_gettype and vim.fn.win_gettype() -- not reliable; keep fallback
	local dp = vim.fn.getwinvar(0, "diffpos", "")
	return type(dp) == "string" and dp:match("left") ~= nil
end

local function diff_left_action()
	-- "Left arrow" should act "toward left":
	-- If you're on left window, going left means "take from other" (do) is intuitive (pull from right into left).
	-- If you're on right window, going left means "push to other" (dp) (send right->left).
	if diff_is_left_window() then
		vim.cmd("normal! do")
	else
		vim.cmd("normal! dp")
	end
end

local function diff_right_action()
	-- Mirror of left_action:
	if diff_is_left_window() then
		vim.cmd("normal! dp")
	else
		vim.cmd("normal! do")
	end
end

local function set_diff_arrow_maps(bufnr)
	local opts = { buffer = bufnr, silent = true, noremap = true }

	vim.keymap.set("n", "<Up>", "[c", vim.tbl_extend("force", opts, { desc = "Diff: next hunk" }))
	vim.keymap.set("n", "<Down>", "]c", vim.tbl_extend("force", opts, { desc = "Diff: prev hunk" }))

	vim.keymap.set("n", "<Left>", diff_left_action, vim.tbl_extend("force", opts, { desc = "Diff: get/put (context)" }))
	vim.keymap.set(
		"n",
		"<Right>",
		diff_right_action,
		vim.tbl_extend("force", opts, { desc = "Diff: put/get (context)" })
	)
end

-- Apply mappings whenever a diff window is entered OR diff is enabled
vim.api.nvim_create_autocmd({ "BufWinEnter", "OptionSet" }, {
	pattern = { "*", "diff" },
	callback = function(args)
		if vim.wo.diff then
			set_diff_arrow_maps(args.buf)
		end
	end,
})

-----------------------------------------------------------
-- Appearance
-----------------------------------------------------------
vim.opt.fillchars:append({ diff = "╱" })

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		-- Darken deleted/filler area (DiffDelete often affects the filler).
		-- Read the theme's background first so we preserve the red while only
		-- dimming the fg of the ╱ slash character.
		local hl = vim.api.nvim_get_hl(0, { name = "DiffDelete", link = false })
		vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#555555", bg = hl.bg })

		-- Optional: also tone down these if they're too bright
		-- vim.api.nvim_set_hl(0, "DiffAdd",    { fg = "#335533", bg = "NONE" })
		-- vim.api.nvim_set_hl(0, "DiffChange", { fg = "#444466", bg = "NONE" })
		-- vim.api.nvim_set_hl(0, "DiffText",   { fg = "#7777aa", bg = "NONE" })
	end,
})
