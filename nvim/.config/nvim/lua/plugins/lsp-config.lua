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

			-- common on_attach for LSP keymaps (per-buffer)
			local on_attach = function(client, bufnr)
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>rr", vim.lsp.buf.references, bufopts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
				-- format on save if supported
			end

			-- register & enable each server
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

			vim.lsp.config("roslyn", {})
			-- NOTE: do *not* call vim.lsp.enable("roslyn") here;
			-- roslyn.nvim handles enabling the client when C# files open.
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
				view = {
					-- make it actually visible
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
