-- lua/plugins/lsp-config.lua
return {
	-- mason
	{
		"williamboman/mason.nvim",
		config = function()
			-- Standard Mason setup, but with the extra registry for roslyn/rzls
			require("mason").setup({
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			})

			-- Optional: auto-install tools
			local mr_ok, mr = pcall(require, "mason-registry")
			if not mr_ok then
				return
			end

			local tools = {

				-- LSP binaries:
				"html-lsp",
				"css-lsp",
				"eslint-lsp",
				"typescript-language-server",
				"json-lsp",

				-- formatters / tools:
				"csharpier",
				"prettier",
				"stylua",
				"xmlformatter",

				-- C# / Razor binaries
				"roslyn",
				"rzls",
			}

			for _, tool in ipairs(tools) do
				local ok, pkg = pcall(mr.get_package, tool)
				if ok and not pkg:is_installed() then
					pkg:install()
				end
			end
		end,
	},

	-- mason-lspconfig: ensure servers are installed, then register configs via vim.lsp.config
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			-- list servers you want installed / enabled
			local servers = { "lua_ls", "pyright" }

			-- install servers via mason
			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_installation = true,
			})

			-- common capabilities (adds cmp support if available)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			-- === unified on_attach for ALL LSPs (C#, Python, Lua, etc.) ===
			local on_attach = function(client, bufnr)
				local map = function(mode, keys, func, desc)
					if desc then
						desc = "LSP: " .. desc
					end
					vim.keymap.set(mode, keys, func, {
						buffer = bufnr,
						noremap = true,
						silent = true,
						desc = desc,
					})
				end

				-- Navigation
				map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
				map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
				map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
				map("n", "gr", vim.lsp.buf.references, "Goto References")
				map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
				map("n", "<gk>", vim.lsp.buf.signature_help, "Signature Help")

				-- Refactor / workspace
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
				map("v", "<leader>ca", vim.lsp.buf.code_action, "Code Action (Range)")
				map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace Add Folder")
				map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace Remove Folder")
				map("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, "Workspace List Folders")

				-- Diagnostics
				map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
				map("n", "<leader>e", vim.diagnostic.open_float, "Line Diagnostics")
				map("n", "<leader>Q", function()
					vim.diagnostic.setqflist({ bufnr = 0, open = true })
				end, "Buffer Diagnostics to Quickfix")

				-- You can add language-specific tweaks here if needed:
				-- if client.name == "roslyn" then ... end
				-- if client.name == "pyright" then ... end
			end

			-- register & enable each "classic" server
			for _, name in ipairs(servers) do
				-- try to load a per-server config file: lua/lsp/<name>.lua
				local ok, server_opts = pcall(require, "lsp." .. name)
				if not ok then
					server_opts = {}
				end

				-- provide default on_attach/capabilities if not specified by the file
				server_opts.on_attach = server_opts.on_attach or on_attach
				server_opts.capabilities = server_opts.capabilities or capabilities

				-- register the server config with the new API
				vim.lsp.config(name, server_opts)

				-- enable the server (call pcall to avoid hard errors during changes)
				pcall(vim.lsp.enable, name)
			end

			-- === Roslyn: use the SAME on_attach + capabilities ===
			vim.lsp.config("roslyn", {
				on_attach = on_attach,
				capabilities = capabilities,
				-- add Roslyn-specific settings here later if you want
			})
			-- NOTE: do NOT call vim.lsp.enable("roslyn"); roslyn.nvim handles that.

			-- IMPORTANT: vim diagnostic configuration AFTER LSPs are loaded
			vim.diagnostic.config({
				underline = false,
				virtual_text = false, -- disable inline text
				update_in_insert = false,
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})
		end,
	},

	-- keep nvim-lspconfig plugin installed, but we don't call the legacy setup()
	{ "neovim/nvim-lspconfig" },
	{
		"j-hui/fidget.nvim",
		version = "*", -- keep on a tagged release
		event = "LspAttach", -- load only when an LSP attaches
		opts = {
			-- LSP progress (this is what you want)
			progress = {},

			-- Notification subsystem (we keep it *not* overriding vim.notify)
			notification = {
				override_vim_notify = false, -- IMPORTANT: do NOT touch vim.notify
				window = {
					winblend = 0, -- 0 = opaque, 100 = fully transparent
				},
			},
		},
	},
	{
		"seblyng/roslyn.nvim",
		---@module 'roslyn.config'
		---@type RoslynNvimConfig
		ft = { "cs", "razor" },
		opts = {
			-- your configuration comes here; leave empty for default settings
		},
	},
}
