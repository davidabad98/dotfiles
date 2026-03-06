-- lua/plugins/opencode.lua
--
-- When inside tmux, opencode runs in a dedicated tmux window started with
-- `opencode --port <port>` where <port> is derived from the tmux session ID
-- (11438 + session_index, never 11437). Every Neovim instance in the same
-- tmux session connects to that port, so multiple simultaneous sessions each
-- get an isolated opencode instance with no cross-talk.
--
-- Outside tmux the fixed port 11437 is used so the two paths can never
-- accidentally share a server even when session $0 is active.
return {
	"nickjvandyke/opencode.nvim",
	version = "*",
	-- Load on demand; keys below tell lazy which keymaps trigger the load.
	lazy = true,
	keys = {
		{ "<leader>ao", mode = { "n", "x" }, desc = "Ask opencode about selection/cursor" },
		{ "<leader>as", mode = { "n", "x" }, desc = "Select opencode action" },
		{ "<leader>ad", mode = "n", desc = "Ask opencode to review git diff" },
		{ "go", mode = { "n", "x" }, desc = "Add range to opencode" },
		{ "goo", mode = "n", desc = "Add line to opencode" },
		{ "<S-C-u>",    mode = "n",          desc = "Scroll opencode up" },
		{ "<S-C-d>",    mode = "n",          desc = "Scroll opencode down" },
		{ "<leader>an", mode = "n",          desc = "New opencode session" },
		{ "<leader>ax", mode = "n",          desc = "Interrupt opencode" },
	},
	config = function()
		-- Determine the port for this context:
		--   • Inside tmux  → session-specific port from configs.tmux
		--                     (tmux.lua is loaded eagerly by init.lua, so
		--                      require("configs.tmux") hits the module cache)
		--   • Outside tmux → fixed fallback 11437
		local tmux_mod = require("configs.tmux")
		local port = tmux_mod.get_opencode_port() or 11437
		local in_tmux = vim.env.TMUX and vim.env.TMUX ~= ""

		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				-- The port opencode.nvim will probe and connect to.
				port = port,

				-- Called when opencode.nvim can't reach the server and needs to
				-- start one. In tmux mode we open the dedicated tmux window (which
				-- runs `opencode --port <port>`); the plugin will retry until it
				-- connects. Outside tmux we fall back to an embedded terminal.
				start = function()
					if in_tmux then
						tmux_mod.open_opencode_tmux_window()
					else
						require("opencode.terminal").start("opencode --port " .. port)
					end
				end,

				-- Called when the plugin wants to tear down the server. In tmux
				-- mode we leave the window alive (the user manages its lifecycle);
				-- outside tmux we stop the embedded terminal.
				stop = function()
					if not in_tmux then
						require("opencode.terminal").stop()
					end
				end,

				-- Called by require("opencode").toggle(). In tmux mode we delegate
				-- to open_opencode_tmux_window (same as <leader>ai); outside tmux
				-- we use the embedded terminal toggle.
				toggle = function()
					if in_tmux then
						tmux_mod.open_opencode_tmux_window()
					else
						require("opencode.terminal").toggle("opencode --port " .. port)
					end
				end,
			},
		}

		-- Required for opencode to auto-reload buffers it edits
		vim.o.autoread = true

		-- Ask opencode about visual selection / cursor context
		vim.keymap.set({ "n", "x" }, "<leader>ao", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode about selection/cursor" })

		-- Select from prompts / commands / server controls
		vim.keymap.set({ "n", "x" }, "<leader>as", function()
			require("opencode").select()
		end, { desc = "Select opencode action" })

		-- Review git diff
		vim.keymap.set("n", "<leader>ad", function()
			require("opencode").ask("@diff ")
		end, { desc = "Ask opencode to review git diff" })

		-- Operator: send motion/visual range to opencode ("go<motion>" / "goo" for line)
		--
		-- How the notification works: opencode.operator() always writes a fresh
		-- closure into _G.opencode_prompt_operator (the actual vimscript-callable
		-- operatorfunc) before returning "g@". We immediately wrap that global so
		-- our notification fires when the motion completes — not before. This
		-- avoids any timing issues and works correctly with dot-repeat.
		vim.keymap.set({ "n", "x" }, "go", function()
			local keys = require("opencode").operator("@this ")
			local inner = _G.opencode_prompt_operator
			_G.opencode_prompt_operator = function(kind)
				inner(kind)
				vim.notify("opencode: range sent", vim.log.levels.INFO)
			end
			return keys
		end, { desc = "Add range to opencode", expr = true })

		vim.keymap.set("n", "goo", function()
			local keys = require("opencode").operator("@this ") .. "_"
			local inner = _G.opencode_prompt_operator
			_G.opencode_prompt_operator = function(kind)
				inner(kind)
				vim.notify("opencode: line sent", vim.log.levels.INFO)
			end
			return keys
		end, { desc = "Add line to opencode", expr = true })

		-- Scroll opencode messages — sent via the HTTP API so these work
		-- regardless of whether opencode is in a tmux window or embedded terminal.
		vim.keymap.set("n", "<S-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Scroll opencode up" })

		vim.keymap.set("n", "<S-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Scroll opencode down" })

		-- Session management
		vim.keymap.set("n", "<leader>an", function()
			require("opencode").command("session.new")
		end, { desc = "New opencode session" })

		vim.keymap.set("n", "<leader>ax", function()
			require("opencode").command("session.interrupt")
		end, { desc = "Interrupt opencode" })
	end,
}
