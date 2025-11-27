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

local function open_lazygit_tmux_window()
	-- 1. Require tmux (we must be *inside* tmux: TMUX env var)
	if not vim.env.TMUX or vim.env.TMUX == "" then
		vim.notify("tmux is not running for this Neovim instance", vim.log.levels.INFO)
		return
	end

	-- 2. Require lazygit to exist
	if vim.fn.executable("lazygit") == 0 then
		vim.notify("lazygit not found in $PATH", vim.log.levels.ERROR)
		return
	end

	-- 3. Require that we are inside a git repo
	local git_root = get_git_root()
	if not git_root then
		vim.notify("Not inside a git repository", vim.log.levels.WARN)
		return
	end

	-- 4. Spawn a new tmux window called "lazygit" in that repo
	--    tmux new-window -c <root> -n lazygit lazygit
	local ok, job_id = pcall(vim.fn.jobstart, {
		"tmux",
		"new-window",
		"-c",
		git_root, -- start in repo root
		"-n",
		"lazygit", -- window name
		"lazygit",
	}, {
		detach = true,
	})

	if not ok or job_id <= 0 then
		vim.notify("Failed to create tmux lazygit window", vim.log.levels.ERROR)
	end
end

vim.keymap.set("n", "<leader>gg", open_lazygit_tmux_window, {
	noremap = true,
	silent = true,
	desc = "Open lazygit in a new tmux window at git root",
})

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
