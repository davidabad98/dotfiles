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
			-- more minimal ui
			dapui.setup({
				expand_lines = true,
				controls = { enabled = true }, -- no extra play/step buttons
				floating = { border = "rounded" },
				-- Set dapui window
				render = {
					max_type_length = 60,
					max_value_lines = 200,
				},
				-- Only one layout: just the "scopes" (variables) list at the bottom
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.6 }, -- 60% of the bottom panel
							{ id = "repl", size = 0.4 }, -- 40% of the bottom panel
						},
						size = 15, -- height in lines
						position = "bottom", -- bottom of the screen
					},
				},
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
			vim.keymap.set("n", "<F9>", dap.toggle_breakpoint)
			vim.keymap.set("n", "<F11>", dap.step_into)
			vim.keymap.set("n", "<F12>", dap.step_out)
			vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
			vim.keymap.set("n", "<Leader>B", function()
				dap.set_breakpoint()
			end)
			vim.keymap.set("n", "<Leader>lp", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end)
			vim.keymap.set("n", "<leader>dr", function()
				dap.repl.toggle()
			end, { desc = "DAP REPL toggle" })
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
			vim.keymap.set("n", "<leader>du", function()
				dapui.toggle()
			end, { noremap = true, silent = true, desc = "Toggle DAP UI" })
			vim.keymap.set({ "n", "v" }, "<leader>dw", function()
				dapui.eval(nil, { enter = true })
			end, { noremap = true, silent = true, desc = "Add word under cursor to Watches" })

			-- === Neotest + DAP: debug nearest test ===
			vim.keymap.set("n", "<F6>", function()
				require("neotest").run.run({ strategy = "dap" })
			end, { desc = "Debug nearest test (neotest-dotnet)" })

			vim.keymap.set("n", "<leader>dT", function()
				require("neotest").run.run({ strategy = "dap" })
			end, { desc = "Debug nearest test (neotest-dotnet)" })

			-- 4) (Optional) nicer signs
			vim.fn.sign_define("DapBreakpoint", {
				text = "●",
				texthl = "DiagnosticError",
				linehl = "DiagnosticError",
				numhl = "DiagnosticError",
			})
			vim.fn.sign_define("DapStopped", {
				text = "▶",
				texthl = "DiagnosticWarn",
				linehl = "DapStoppedLine",
				numhl = "DapStoppedLine",
			})
			-- vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticHint" })
			vim.fn.sign_define("DapBreakpointRejected", {
				text = "⭕",
				texthl = "DiagnosticHint",
				linehl = "DiagnosticHint",
				numhl = "DiagnosticHint",
			})

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
			local netcoredbg_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"
			local dotnet = require("configs.nvim-dap-dotnet")
			-- one adapter, two names (guide does this)
			local netcoredbg_adapter = {
				type = "executable",
				command = netcoredbg_path,
				args = { "--interpreter=vscode" },
			}

			-- neotest-dotnet default adapter_name is "netcoredbg"
			dap.adapters.netcoredbg = netcoredbg_adapter -- for neotest-dotnet
			dap.adapters.coreclr = netcoredbg_adapter -- for regular DAP configs

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "launch - netcoredbg",
					request = "launch",
					program = function()
						return dotnet.build_dll_path()
					end,
					-- program = function()
					-- 	-- return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/src/", "file")
					-- 	return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net9.0/", "file")
					-- end,

					-- justMyCode = false,
					-- stopAtEntry = false,
					-- -- program = function()
					-- --   -- todo: request input from ui
					-- --   return "/path/to/your.dll"
					-- -- end,
					-- env = {
					--   ASPNETCORE_ENVIRONMENT = function()
					--     -- todo: request input from ui
					--     return "Development"
					--   end,
					--   ASPNETCORE_URLS = function()
					--     -- todo: request input from ui
					--     return "http://localhost:5050"
					--   end,
					-- },
					-- cwd = function()
					--   -- todo: request input from ui
					--   return vim.fn.getcwd()
					-- end,
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
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"Issafalcon/neotest-dotnet",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-dotnet")({
						dap = {
							-- match the adapter name we defined above
							adapter_name = "netcoredbg",
							-- you can also pass dap args here if needed
							-- args = { justMyCode = false },
						},
					}),
				},
			})
		end,
	},
}
