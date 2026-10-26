local M = {}

local function notify(message, level)
	vim.notify(message, level, { title = "Worktree switcher" })
end

local function get_git_root()
	local cwd = vim.fn.getcwd()
	local bufname = vim.api.nvim_buf_get_name(0)

	if bufname ~= "" and vim.bo.buftype == "" then
		local buffer_dir = vim.fn.isdirectory(bufname) == 1 and bufname or vim.fn.fnamemodify(bufname, ":h")
		if buffer_dir ~= "" then
			cwd = buffer_dir
		end
	end

	local result = vim.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		return nil
	end

	return vim.trim(result.stdout or "")
end

local function parse_worktrees(output)
	local worktrees = {}
	local current

	local function add_current()
		if not current or not current.path or current.bare or current.prunable then
			return
		end
		if vim.fn.isdirectory(current.path) ~= 1 then
			return
		end

		current.branch = current.branch or "detached HEAD"
		table.insert(worktrees, current)
	end

	-- Git's porcelain output is stable and -z keeps unusual paths unambiguous.
	-- https://git-scm.com/docs/git-worktree#_porcelain_format
	for field in output:gmatch("([^%z]+)") do
		local path = field:match("^worktree (.*)$")
		if path then
			add_current()
			current = { path = path }
		elseif current then
			local branch = field:match("^branch (.*)$")
			if branch then
				current.branch = branch:gsub("^refs/heads/", "")
			elseif field == "bare" then
				current.bare = true
			elseif field == "detached" then
				current.branch = "detached HEAD"
			elseif field:match("^prunable") then
				current.prunable = true
			end
		end
	end

	add_current()
	return worktrees
end

local function switch_to(worktree)
	if vim.fn.isdirectory(worktree.path) ~= 1 then
		notify("Worktree no longer exists: " .. worktree.path, vim.log.levels.WARN)
		return
	end

	local previous_cwd = vim.fn.getcwd()
	local ok, err = pcall(vim.api.nvim_set_current_dir, worktree.path)
	if not ok then
		notify("Could not change directory: " .. tostring(err), vim.log.levels.ERROR)
		return
	end

	-- The sessionizer starts projects with `nvim .`; editing the selected
	-- directory gives the current Neovim the same browse-from-root behavior.
	-- Neovim's built-in dir plugin handles editing a directory path:
	-- https://neovim.io/doc/user/plugins/#builtin-plugins
	local opened, open_err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(worktree.path))
	if not opened then
		pcall(vim.api.nvim_set_current_dir, previous_cwd)
		notify(
			"Could not open worktree (unsaved changes may block switching): " .. tostring(open_err),
			vim.log.levels.WARN
		)
		return
	end

	notify("Switched to " .. worktree.branch .. " — " .. worktree.path, vim.log.levels.INFO)
end

function M.switch()
	if vim.fn.executable("git") == 0 then
		notify("Git was not found in PATH", vim.log.levels.ERROR)
		return
	end

	local root = get_git_root()
	if not root then
		notify("Not inside a Git repository", vim.log.levels.WARN)
		return
	end

	local result = vim
		.system({ "git", "-C", root, "worktree", "list", "--porcelain", "-z" }, { text = false })
		:wait()
	if result.code ~= 0 then
		notify(vim.trim(result.stderr or "Could not list Git worktrees"), vim.log.levels.ERROR)
		return
	end

	local worktrees = parse_worktrees(result.stdout or "")
	if #worktrees == 0 then
		notify("No available Git worktrees found", vim.log.levels.INFO)
		return
	end

	vim.ui.select(worktrees, {
		prompt = "Git worktrees",
		format_item = function(worktree)
			local display_path = worktree.path:gsub("\n", "\\n")
			return worktree.branch .. "  " .. display_path
		end,
	}, function(worktree)
		if worktree then
			switch_to(worktree)
		end
	end)
end

vim.keymap.set("n", "<leader>gw", M.switch, { desc = "Switch Git worktree" })

return M
