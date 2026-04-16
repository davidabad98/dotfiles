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
-- Per-session OpenCode port
-----------------------------------------------------------
-- Derives a unique port for this tmux session so multiple simultaneous
-- sessions each get their own opencode instance with no cross-talk.
--
-- Strategy: port = 11438 + session_index  (base 11438, never 11437)
--   11437 is reserved for non-tmux Neovim so the two contexts never share
--   a port even if session $0 is active.
--   tmux session_id looks like "$3"; stripping the "$" gives the index.
--   The result is cached in the tmux session environment (OPENCODE_PORT)
--   so the value is stable even if computed multiple times.
--
-- Returns nil when not running inside tmux.
local function get_opencode_port()
	if not vim.env.TMUX or vim.env.TMUX == "" then
		return nil
	end

	-- Check the tmux session environment first (set on first call)
	local cached = vim.fn.systemlist({ "tmux", "show-environment", "OPENCODE_PORT" })
	if vim.v.shell_error == 0 and cached and #cached > 0 then
		local p = cached[1]:match("^OPENCODE_PORT=(%d+)")
		if p then
			return tonumber(p)
		end
	end

	-- Not yet set: derive from session_id ("$N" → N) and store it
	local id_out = vim.fn.systemlist({ "tmux", "display-message", "-p", "#{session_id}" })
	local session_num = 0
	if id_out and #id_out > 0 then
		local n = id_out[1]:match("%$?(%d+)")
		session_num = tonumber(n) or 0
	end

	local port = 11438 + session_num
	-- Persist for this session only (not global, so other sessions are unaffected)
	vim.fn.jobstart(
		{ "tmux", "set-environment", "OPENCODE_PORT", tostring(port) },
		{ detach = true }
	)
	return port
end

-----------------------------------------------------------
-- Generic opener: open a tmux tool window at git root
-----------------------------------------------------------
---@param opts table
---@field bin string          -- binary name for $PATH check and default window name
---@field run_cmd? string     -- full shell command to execute (defaults to bin)
---@field window_name? string -- tmux window name (defaults to bin)
---@field require_git? boolean -- whether to require git root (default: true)
local function open_tmux_tool_window(opts)
	opts = opts or {}
	local bin = opts.bin or opts.cmd -- opts.cmd kept for backward compat
	if not bin or bin == "" then
		vim.notify("open_tmux_tool_window: opts.bin is required", vim.log.levels.ERROR)
		return
	end

	local run_cmd = opts.run_cmd or bin
	local window_name = opts.window_name or bin
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
	if vim.fn.executable(bin) == 0 then
		vim.notify(bin .. " not found in $PATH", vim.log.levels.ERROR)
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

	-- 5. Otherwise create new window running the tool.
	--    The last argument is passed as a shell-command string by tmux,
	--    so "opencode --port 11438" is correctly parsed by the shell.
	local ok, job_id = pcall(vim.fn.jobstart, {
		"tmux",
		"new-window",
		"-c",
		root,
		"-n",
		window_name,
		run_cmd,
	}, {
		detach = true,
	})

	if not ok or job_id <= 0 then
		vim.notify("Failed to create tmux window for '" .. bin .. "'", vim.log.levels.ERROR)
	end
end

----------------------------------------------------------------
-- Lazygit
----------------------------------------------------------------
local function open_lazygit_tmux_window()
	-- Outside tmux: fall back to lazygit.nvim floating window at git root
	if not vim.env.TMUX or vim.env.TMUX == "" then
		vim.cmd("LazyGitCurrentFile")
		return
	end
	open_tmux_tool_window({
		bin = "lazygit",
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
	-- Outside tmux: fall back to opencode.nvim embedded terminal
	if not vim.env.TMUX or vim.env.TMUX == "" then
		require("opencode").toggle()
		return
	end
	local port = get_opencode_port()
	open_tmux_tool_window({
		bin = "opencode",
		run_cmd = "opencode --port " .. port,
		window_name = "opencode",
		require_git = true,
	})
end

vim.keymap.set({ "n", "t" }, "<leader>ai", open_opencode_tmux_window, {
	noremap = true,
	silent = true,
	desc = "Toggle opencode (tmux window or embedded terminal)",
})

----------------------------------------------------------------
-- Module exports (used by lua/plugins/opencode.lua)
----------------------------------------------------------------
return {
	get_opencode_port = get_opencode_port,
	open_opencode_tmux_window = open_opencode_tmux_window,
}
