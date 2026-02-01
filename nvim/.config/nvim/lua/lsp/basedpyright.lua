-- lua/lsp/basedpyright.lua
return {
	-- Optional: limit filetypes (basedpyright already defaults)
	filetypes = { "python" },

	-- Settings for basedpyright
	settings = {
		basedpyright = {
			analysis = {
				-- recommended defaults; tune to taste
				typeCheckingMode = "basic", -- off, basic, strict
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace", -- analyze entire project
				autoSearchPaths = true,
				autoImportCompletions = true, -- Enable auto-import suggestions
			},
		},
	},

	-- Basedpyright: language features + type checking with better code actions than pyright.
	-- Ruff (via none-ls): linting + formatting.
}
