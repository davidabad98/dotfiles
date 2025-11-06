-- lua/plugins/debugging.lua
return {
	-- Core DAP + UI
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio", -- <— required by dap-ui
			"jay-babu/mason-nvim-dap.nvim", -- optional: auto-install adapters
			"williamboman/mason.nvim",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			-- 1) UI setup (must be called once)
			dapui.setup({
				-- you can customize icons/layouts here if you like
			})

			-- 2) Open/close UI on session start/stop
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- 3) Keymaps
			vim.keymap.set("n", "<F5>", dap.continue)
			vim.keymap.set("n", "<F10>", dap.step_over)
			vim.keymap.set("n", "<F11>", dap.step_into)
			vim.keymap.set("n", "<F12>", dap.step_out)
			vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
			vim.keymap.set("n", "<Leader>B", function()
				dap.set_breakpoint()
			end)
			vim.keymap.set("n", "<Leader>lp", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end)
			vim.keymap.set("n", "<Leader>dr", dap.repl.open)
			vim.keymap.set("n", "<Leader>dl", dap.run_last)
			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end)
			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end)
			vim.keymap.set("n", "<Leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end)
			vim.keymap.set("n", "<Leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end)

			-- 4) (Optional) nicer signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticHint" })

			-- 5) Auto-install / hook adapters via Mason
			require("mason-nvim-dap").setup({
				ensure_installed = {
					"python", -- debugpy
					"netcoredbg", -- .NET Core
					-- "js"        -- optional: vscode-js-debug
				},
				automatic_installation = true,
				handlers = {}, -- use defaults
			})

			----------------------------------------------------------------
			-- Language adapters/configs
			----------------------------------------------------------------
			-- === Python (debugpy) ===
			local dbgpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
			dap.adapters.python = {
				type = "executable",
				command = dbgpy,
				args = { "-m", "debugpy.adapter" },
			}
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					console = "integratedTerminal",
					pythonPath = function()
						-- Prefer venv if active; else fallback to system python
						local venv = os.getenv("VIRTUAL_ENV")
						if venv and #venv > 0 then
							return venv .. "/bin/python"
						end
						return "python3"
					end,
				},
			}

			-- === .NET (netcoredbg) ===
			local netcoredbg = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"
			dap.adapters.coreclr = {
				type = "executable",
				command = netcoredbg,
				args = { "--interpreter=vscode" },
			}
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch",
					request = "launch",
					program = function()
						-- point to your built DLL (Debug/Release as appropriate)
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
				},
			}

			-- (Optional) JS/TS via vscode-js-debug:
			-- local js_debug = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
			-- dap.adapters["pwa-node"] = {
			--   type = "server",
			--   host = "127.0.0.1",
			--   port = "${port}",
			--   executable = { command = "node", args = { js_debug, "${port}" } },
			-- }
			-- dap.configurations.javascript = {
			--   { type = "pwa-node", request = "launch", name = "Launch file", program = "${file}", cwd = "${workspaceFolder}" },
			-- }
			-- dap.configurations.typescript = dap.configurations.javascript
		end,
	},
}
