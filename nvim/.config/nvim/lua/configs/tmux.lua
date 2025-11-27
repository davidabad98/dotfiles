-- lua/configs/tmux.lua

local function get_git_root()
	-- Prefer buffer dir; fall back to cwd
	local buf_dir = vim.fn.expand("%:p:h")
	local cwd = (buf_dir ~= "" and buf_dir) or vim.loop.cwd()

	local result = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
	if vim.v.shell_error ~= 0 or #result == 0 then
		return nil
	end

	return result[1]
end

-- Check if a tmux window with a given name exists in the *current* tmux session
local function tmux_window_exists(name)
	local windows = vim.fn.systemlist({ "tmux", "list-windows", "-F", "#{window_name}" })
	if vim.v.shell_error ~= 0 or not windows then
		return false
	end

	for _, w in ipairs(windows) do
		if w == name then
			return true
		end
	end
	return false
end

-- Switch to a tmux window by name in the current session
local function tmux_select_window(name)
	local ok, job_id = pcall(vim.fn.jobstart, {
		"tmux",
		"select-window",
		"-t",
		name,
	}, {
		detach = true,
	})

	if not ok or job_id <= 0 then
		vim.notify("Failed to switch to tmux window '" .. name .. "'", vim.log.levels.ERROR)
	end
end

-----------------------------------------------------------
-- Generic opener: open a tmux tool window at git root
-----------------------------------------------------------
---@param opts table
---@field cmd string        -- command to run (must be in $PATH)
---@field window_name? string -- tmux window name (defaults to cmd)
---@field require_git? boolean -- whether to require git root (default: true)
local function open_tmux_tool_window(opts)
	opts = opts or {}
	local cmd = opts.cmd
	if not cmd or cmd == "" then
		vim.notify("open_tmux_tool_window: opts.cmd is required", vim.log.levels.ERROR)
		return
	end

	local window_name = opts.window_name or cmd
	local require_git = opts.require_git
	if require_git == nil then
		require_git = true
	end

	-- 1. Require tmux
	if not vim.env.TMUX or vim.env.TMUX == "" then
		vim.notify("tmux is not running for this Neovim instance", vim.log.levels.INFO)
		return
	end

	-- 2. Require the tool binary to exist
	if vim.fn.executable(cmd) == 0 then
		vim.notify(cmd .. " not found in $PATH", vim.log.levels.ERROR)
		return
	end

	-- 3. Determine working directory
	local cwd = vim.loop.cwd()
	local root = cwd

	if require_git then
		local git_root = get_git_root()
		if not git_root then
			vim.notify("Not inside a git repository", vim.log.levels.WARN)
			return
		end
		root = git_root
	end

	-- 4. If window already exists, just switch to it
	if tmux_window_exists(window_name) then
		tmux_select_window(window_name)
		return
	end

	-- 5. Otherwise create new window running the tool
	--    tmux new-window -c <root> -n <window_name> <cmd>
	local ok, job_id = pcall(vim.fn.jobstart, {
		"tmux",
		"new-window",
		"-c",
		root,
		"-n",
		window_name,
		cmd,
	}, {
		detach = true,
	})

	if not ok or job_id <= 0 then
		vim.notify("Failed to create tmux window for '" .. cmd .. "'", vim.log.levels.ERROR)
	end
end

----------------------------------------------------------------
-- Lazygit
----------------------------------------------------------------
local function open_lazygit_tmux_window()
	open_tmux_tool_window({
		cmd = "lazygit",
		window_name = "lazygit",
		require_git = true,
	})
end

vim.keymap.set("n", "<leader>gg", open_lazygit_tmux_window, {
	noremap = true,
	silent = true,
	desc = "Open lazygit in a tmux window at git root (reuse if exists)",
})

----------------------------------------------------------------
-- Tmux sessionizer
----------------------------------------------------------------
-- Open the tmux sessionizer from inside Neovim
-- NOTE: requires tmux; inside tmux it opens a popup, outside it spawns a new tmux session/window
local sessionizer = vim.fn.expand("~/.local/bin/tmux-sessionizer")

vim.keymap.set("n", "<C-f>", function()
	if vim.fn.filereadable(sessionizer) == 0 then
		vim.notify("tmux-sessionizer not found at " .. sessionizer, vim.log.levels.ERROR)
		return
	end
	if not vim.env.TMUX then
		-- Not in tmux
		vim.notify("tmux not started")
		return
	end
	-- Run it inside a new tmux window if we're already in tmux
	vim.fn.jobstart({ "tmux", "display-popup", "-E", sessionizer }, { detach = true })
end, { noremap = true, silent = true, desc = "Project switcher (tmux sessionizer)" })

----------------------------------------------------------------
-- OpenCode
----------------------------------------------------------------
local function open_opencode_tmux_window()
	open_tmux_tool_window({
		cmd = "opencode",
		window_name = "opencode",
		require_git = true,
	})
end

vim.keymap.set("n", "<leader>ai", open_opencode_tmux_window, {
	noremap = true,
	silent = true,
	desc = "Open opencode in a tmux window at git root (reuse if exists)",
})
